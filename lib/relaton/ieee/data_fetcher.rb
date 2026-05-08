require "etc"
require "zip"
require_relative "../ieee"
require_relative "converter/bibxml"
require_relative "idams_parser"
require_relative "rawbib_id_parser"

module Relaton
  module Ieee
    class DataFetcher < Core::DataFetcher
      RELATION_TYPES = {
        "S" => { type: "obsoletedBy" },
        "V" => { type: "updates", description: "revises" },
        "T" => { type: "updates", description: "amends" },
        "C" => { type: "updates", description: "corrects" },
        "O" => { type: "adoptedFrom" },
        "P" => { type: "complementOf", description: "supplement" },
        "N" => false, "G" => false,
        "F" => false, "I" => false,
        "E" => false, "B" => false, "W" => false
      }.freeze

      #
      # Convert documents from `ieee-rawbib` dir (IEEE dataset) to BibYAML/BibXML
      #
      def log_error(msg)
        Util.error msg
      end

      def fetch(_source = nil)
        files = Dir["ieee-rawbib/**/*.{xml,zip}"].reject { |f| f["Deleted_"] }
        files = prefilter_winners(files) unless ENV["IEEE_FETCH_PREFILTER"] == "0"
        process_files(files)
        update_relations
        report_errors
      end

      # @return [Hash] list of AMSID => PubID
      def backrefs
        @backrefs ||= {}
      end

      # @return [Hash] list of docnumber => parsed bib (cache for update_relations)
      def docs
        @docs ||= {}
      end

      # @return [Hash] docnumber => max global glob-index whose write was
      # accepted by commit_doc. Populated only when running with parallel
      # workers (writes are staged to per-glob-index suffixed paths and
      # reconciled into the final filename after the parsing phase).
      def saved_writes
        @saved_writes ||= {}
      end

      # Mutex guarding worker-thread mutations of shared state during parse.
      def mutex
        @mutex ||= Mutex.new
      end

      #
      # Save unresolved relation reference. Called from worker threads via
      # IdamsParser#parse_relation, so mutates crossrefs under a mutex.
      #
      # @param [String] docnumber of main document
      # @param [Nokogiri::XML::Element] amsid relation data
      #
      def add_crossref(docnumber, amsid)
        return if RELATION_TYPES[amsid.type] == false

        ref = { amsid: amsid.date_string, type: amsid.type }
        mutex.synchronize { crossrefs[docnumber] << ref }
      end

      #
      # Create relation instance
      #
      # @param [String] type IEEE relation type
      # @param [String] fref reference
      #
      # @return [RelatonBib::DocumentRelation]
      #
      def create_relation(type, fref)
        unless RELATION_TYPES.key? type
          Util.warn "Unknown relation type: '#{type}' for reference '#{fref}'", key: fref
          return
        end
        return if RELATION_TYPES[type] == false

        docid = Bib::Docidentifier.new(type: "IEEE", content: fref, primary: true)
        bib = ItemData.new formattedref: Bib::Formattedref.new(content: fref), docidentifier: [docid]
        description = create_relation_description type
        Bib::Relation.new(type: RELATION_TYPES[type][:type], description: description, bibitem: bib)
      end

      private

      def create_relation_description(type)
        desc = RELATION_TYPES[type][:description] if RELATION_TYPES[type]
        return unless desc

        desc && Bib::LocalizedMarkedUpString.new(content: desc, language: "en", script: "Latn")
      end

      # @return [Hash] list of PubID => list of unresolved relations
      def crossrefs
        @crossrefs ||= Hash.new { |hash, key| hash[key] = [] }
      end

      #
      # Extract XML file from zip archive
      #
      # @param [String] file path to achive
      #
      # @return [String] file content
      #
      def read_zip(file)
        Zip::File.open(file) do |zf|
          entry = zf.glob("**/*.xml").first
          entry.get_input_stream.read
        end
      end

      #
      # Pre-filter the input file list down to the subset that actually
      # has to be fully parsed.
      #
      # The IEEE rawbib dataset has ~50× duplication: every docnumber
      # appears in `cache/` plus most `updates.YYYYMMDD/` folders. The
      # original semantic is "latest update wins on disk", so for any
      # docnumber that has at least one updates-folder file, the cache
      # file's parse result is just thrown away. Pre-filter avoids
      # parsing those throwaway files entirely.
      #
      # The cheap path here only has to extract three small XML elements
      # (normtitle, stdnumber, standard_id) per file — done with
      # regex on the raw XML so we skip lutaml-model's heavy DOM-to-
      # object construction (which is what dominates fetch time).
      #
      # Selection rules:
      #   - For each docnumber with any updates-folder entry: keep only
      #     the highest-glob-idx updates-folder file.
      #   - For docnumbers with cache-folder entries only: keep all
      #     of them (commit_doc's matches-stdnumber dedup handles them).
      #   - Files where the cheap parse couldn't compute a docnumber
      #     are kept as-is — the full parse will surface any real error.
      #
      # Disable with IEEE_FETCH_PREFILTER=0.
      #
      def prefilter_winners(files)
        threshold = Integer(ENV["IEEE_FETCH_PREFILTER_MIN"] || 200)
        return files if files.size < threshold

        procs = Integer(ENV["IEEE_FETCH_PROCESSES"] || Etc.nprocessors)
        index = procs <= 1 ? prefilter_serial(files) : prefilter_parallel(files, procs)
        select_prefilter_winners(index, files.size)
      end

      def prefilter_serial(files)
        files.each_with_index.map { |f, i| extract_index_entry(i, f) }.compact
      end

      def prefilter_parallel(files, procs) # rubocop:disable Metrics/MethodLength
        batch_size = Integer(ENV["IEEE_PREFILTER_BATCH"] || 5000)
        batches = files.each_slice(batch_size).each_with_index.to_a

        next_batch = 0
        inflight   = {}
        collected  = []

        procs.times do
          break if next_batch >= batches.size

          inflight.merge!(spawn_prefilter_batch(*batches[next_batch], batch_size))
          next_batch += 1
        end

        until inflight.empty?
          pid = Process.wait
          collected << inflight.delete(pid)

          if next_batch < batches.size
            inflight.merge!(spawn_prefilter_batch(*batches[next_batch], batch_size))
            next_batch += 1
          end
        end

        index = []
        collected.each do |path|
          next unless path && File.exist?(path) && File.size(path).positive?

          index.concat(Marshal.load(File.binread(path)))
          File.unlink(path)
        end
        index
      end

      def spawn_prefilter_batch(batch_files, batch_idx, batch_size)
        require "tmpdir"
        require "securerandom"
        state_path = File.join(
          Dir.tmpdir,
          "ieee_prefilter_#{Process.pid}_#{batch_idx}_#{SecureRandom.hex(4)}.bin",
        )
        base_idx = batch_idx * batch_size

        pid = Process.fork do
          entries = batch_files.each_with_index.map do |file, i|
            extract_index_entry(base_idx + i, file)
          end.compact
          File.binwrite(state_path, Marshal.dump(entries))
          exit!(0)
        end
        { pid => state_path }
      end

      #
      # Cheap-parse one file: read XML, regex-extract three fields,
      # compute docnumber via the existing RawbibIdParser. Returns
      # `[glob_idx, file, docnumber_or_nil, in_updates_folder?]`.
      #
      def extract_index_entry(idx, file)
        xml = case File.extname(file)
              when ".zip" then read_zip(file)
              when ".xml" then File.read(file, encoding: "UTF-8")
              end
        return nil unless xml
        return nil if cheap_extract_field(xml, "standard_id") == "0"

        normtitle = cheap_extract_field(xml, "normtitle")
        stdnumber = cheap_extract_field(xml, "stdnumber")
        docnumber = nil
        if normtitle && stdnumber
          pubid = RawbibIdParser.parse(normtitle, stdnumber)
          docnumber = pubid&.to_id
        end
        [idx, file, docnumber, file.include?("/updates.")]
      rescue StandardError
        # Cheap parse couldn't handle this file — keep it; full parse will
        # either succeed or surface the real error.
        [idx, file, nil, file.include?("/updates.")]
      end

      def cheap_extract_field(xml, tag)
        m = xml.match(%r{<#{tag}[^>]*?>(?:<!\[CDATA\[)?(.*?)(?:\]\]>)?</#{tag}>}m)
        m && m[1].strip
      end

      def select_prefilter_winners(index, total)
        unknown = index.select { |e| e[2].nil? }
        by_doc  = index.reject { |e| e[2].nil? }.group_by { |e| e[2] }

        selected = []
        by_doc.each_value do |entries|
          updates = entries.select { |e| e[3] }
          if updates.any?
            selected << updates.max_by { |e| e[0] }
          else
            selected.concat(entries)
          end
        end

        kept = (selected + unknown).sort_by { |e| e[0] }.map { |e| e[1] }
        Util.warn "Prefilter: #{total} input files -> #{kept.size} winners " \
                  "(#{(100.0 * kept.size / total).round(1)}%)"
        kept
      end

      #
      # Parse files across a pool of short-lived forked workers. Each
      # worker processes one bounded batch (IEEE_FETCH_BATCH files,
      # default 5000), writes its output YAMLs to disk, marshals its
      # local backrefs / crossrefs / errors to a tmp file, and exits.
      # The parent keeps `procs` workers in flight; as each one exits
      # it merges that worker's state and spawns the next batch.
      #
      # Why short-lived workers, not one long-running shard per core:
      # Ruby's heap grows monotonically and the VM doesn't return
      # freed memory to the OS, so a child that parses 50k files ends
      # up at 1+ GB RSS even with the docs cache disabled. With ten
      # such children the box swaps and slows to a crawl. Exiting a
      # child after a batch of a few thousand files lets the OS
      # reclaim its heap; the next fork starts fresh from the parent's
      # baseline. Fork is cheap (copy-on-write), so the overhead is
      # negligible compared to the memory savings.
      #
      # Caveats from sharding (same as the previous design):
      #   - Cross-batch duplicates: when the same docnumber appears in
      #     multiple batches, the last-finishing batch's write wins.
      #     Merged backrefs/crossrefs are still complete, so
      #     update_relations resolves cross-refs correctly.
      #   - "Document exists" warnings are per-batch, so cross-batch
      #     duplicates may not log a warning. Logging only.
      #
      # @param [Array<String>] files paths to rawbib XML/zip files
      #
      def process_files(files) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        procs = Integer(ENV["IEEE_FETCH_PROCESSES"] || Etc.nprocessors)
        procs = 1 if files.empty? || procs < 2 || files.size < procs * 2

        return run_shard(files, 0) if procs <= 1

        batch_size = Integer(ENV["IEEE_FETCH_BATCH"] || 1000)
        batches = files.each_slice(batch_size).each_with_index.to_a

        state_paths = run_worker_pool(batches, procs)
        merge_state_files(state_paths)
        reconcile_staged_outputs
      end

      #
      # Promote the highest-glob-index staged write per docnumber to its
      # final on-disk filename, then delete any leftover staged files.
      # Restores exact "latest update wins" semantics across batches:
      # without this pass, a slow batch finishing late could overwrite a
      # newer update that an earlier-completing batch had already saved.
      #
      def reconcile_staged_outputs
        return if saved_writes.empty?

        saved_writes.each do |docnumber, max_idx|
          final  = output_file(docnumber)
          winner = "#{final}.#{max_idx}"
          File.rename(winner, final) if File.exist?(winner)
        end

        # Stragglers: any remaining staged files (losing duplicates,
        # or bib filenames that didn't end up in saved_writes due to a
        # crash) get cleaned up so they don't pollute `data/`.
        Dir.glob(File.join(@output, "*.#{@ext}.*")).each do |f|
          File.unlink(f)
        rescue StandardError
          # ignore — best-effort cleanup
        end
      end

      #
      # Merge all batch state files into the parent's hashes. Runs once,
      # after the worker pool has drained, so the parent's heap only
      # has to hold the cumulative merged state (small) plus one batch's
      # transient marshaled payload at a time.
      #
      def merge_state_files(state_paths)
        state_paths.each_with_index do |path, i|
          merge_batch_state(path)
          # Periodic GC.start keeps the transient marshal allocations
          # from piling up over hundreds of merges.
          GC.start if (i % 50).zero?
        end
      end

      #
      # Maintain `procs` concurrent short-lived workers. Each Process.wait
      # call blocks until any worker exits; we collect its state-file
      # path and spawn the next batch (if any).
      #
      # Critically, we do NOT merge state into the parent's hashes here.
      # Loading and merging dozens of MB of marshaled hashes per batch
      # bloated the parent's heap into the multi-GB range, and every
      # subsequent fork inherited that bloat via copy-on-write — driving
      # the box into swap. By deferring all merging to after the parsing
      # phase, the parent stays at ~baseline RSS while children are alive,
      # so each fork's COW baseline is small.
      #
      # @return [Array<String>] state-file paths in completion order
      #
      def run_worker_pool(batches, procs) # rubocop:disable Metrics/MethodLength
        next_batch = 0
        inflight   = {} # pid => state_path
        collected  = []

        procs.times do
          break if next_batch >= batches.size

          inflight.merge!(spawn_batch(*batches[next_batch]))
          next_batch += 1
        end

        until inflight.empty?
          pid = Process.wait
          collected << inflight.delete(pid)

          if next_batch < batches.size
            inflight.merge!(spawn_batch(*batches[next_batch]))
            next_batch += 1
          end
        end

        collected
      end

      #
      # Fork one short-lived worker for a single batch. Returns a
      # `{pid => state_path}` Hash. The worker writes its marshaled
      # local state to `state_path` then exits; the tmp file is read
      # and unlinked by the parent in `merge_batch_state`.
      #
      def spawn_batch(batch_files, batch_idx) # rubocop:disable Metrics/MethodLength
        require "tmpdir"
        require "securerandom"
        state_path = File.join(
          Dir.tmpdir,
          "ieee_fetch_#{Process.pid}_#{batch_idx}_#{SecureRandom.hex(4)}.bin",
        )
        base_idx = batch_idx * Integer(ENV["IEEE_FETCH_BATCH"] || 1000)

        pid = Process.fork do
          batch_files.each_with_index do |file, i|
            glob_idx = base_idx + i
            result = parse_entry(glob_idx, file)
            next unless result

            _, _, doc, bib, local_errors = result
            merge_errors(local_errors)
            commit_doc(doc, bib, file, glob_idx)
          end
          File.binwrite(state_path, Marshal.dump(
            backrefs:     backrefs,
            crossrefs:    {}.merge(crossrefs),
            errors:       {}.merge(@errors),
            saved_writes: saved_writes,
          ))
          exit!(0)
        end

        { pid => state_path }
      end

      #
      # Read one batch's marshaled state, merge into parent state,
      # remove the tmp file. Tolerates a missing/empty file (worker
      # crash) by treating it as an empty merge.
      #
      def merge_batch_state(state_path)
        if state_path && File.exist?(state_path) && File.size(state_path).positive?
          payload = Marshal.load(File.binread(state_path))
          merge_shard_state(payload)
        end
      ensure
        File.unlink(state_path) if state_path && File.exist?(state_path)
      end

      #
      # Merge one child's per-shard state into the parent's. backrefs uses
      # ||= so the lowest-shard-id value wins for any amsid/docnumber pair
      # that happens to appear in multiple shards (in practice they agree).
      # `saved_writes` tracks the highest glob-index at which any worker
      # saved a doc, so the parent can later rename the winning staged
      # file to its final name.
      #
      def merge_shard_state(state)
        state[:backrefs].each { |amsid, content| backrefs[amsid] ||= content }
        state[:crossrefs].each { |dnum, refs| crossrefs[dnum].concat(refs) }
        state[:errors].each { |k, v| @errors[k] &&= v }
        (state[:saved_writes] || {}).each do |dnum, idx|
          prev = saved_writes[dnum]
          saved_writes[dnum] = idx if prev.nil? || idx > prev
        end
      end

      #
      # Process one shard sequentially. Either runs in a forked child or,
      # when procs == 1, in the parent.
      #
      # `shard` is an array of [original_idx, file] tuples (or, when
      # called from the procs==1 fallback, just the array of file paths
      # — we normalize below).
      #
      def run_shard(shard, _shard_idx)
        shard.each_with_index do |entry, i|
          idx, file = entry.is_a?(Array) ? entry : [i, entry]
          result = parse_entry(idx, file)
          next unless result

          _, _, doc, bib, local_errors = result
          merge_errors(local_errors)
          commit_doc(doc, bib, file)
        end
      end

      #
      # Worker-thread entry point: read file, parse XML, build bib.
      # Returns nil for files we should skip; otherwise a tuple consumed
      # in submission order by the main-thread commit loop.
      #
      # @param [Integer] idx original glob index (preserves dedup order)
      # @param [String] file path to rawbib file
      #
      # @return [Array, nil] [idx, file, doc, bib, local_errors] or nil
      #
      def parse_entry(idx, file)
        xml = case File.extname(file)
              when ".zip" then read_zip file
              when ".xml" then File.read file, encoding: "UTF-8"
              end
        doc = begin
          ::Ieee::Idams::Publication.from_xml(xml)
        rescue StandardError
          Util.warn "Empty file: `#{file}`"
          return nil
        end
        return nil if doc.publicationinfo&.standard_id == "0"

        local_errors = Hash.new(true)
        bib = IdamsParser.new(doc, self, local_errors).parse
        if bib.docnumber.nil?
          Util.warn "PubID parse error. Normtitle: `#{doc.normtitle}`, file: `#{file}`"
          return nil
        end
        [idx, file, doc, bib, local_errors]
      rescue StandardError => e
        Util.error "File: #{file}\n#{e.message}\n#{e.backtrace}"
        nil
      end

      #
      # Merge a worker's local errors hash into the shared @errors hash,
      # preserving the existing AND semantics (`@errors[k] &&= v`).
      #
      def merge_errors(local_errors)
        local_errors.each { |k, v| @errors[k] &&= v }
      end

      #
      # Dedup against backrefs and save. This runs once per parsed file —
      # in the parent for the procs==1 fallback, or in each forked child
      # for its shard. Same logic the old fetch_doc tail had, plus
      # optional staged-output bookkeeping when `glob_idx` is provided.
      #
      # When `glob_idx` is given (parallel mode), save_doc writes to a
      # per-glob-index suffixed path; the parent reconciles after the
      # parsing phase and renames the highest-glob-index winner per
      # docnumber to the final filename. This preserves the original
      # "latest update wins on disk" semantic across batch boundaries
      # — without it, a slow batch finishing late could overwrite a
      # newer update written by an earlier-completing batch.
      #
      def commit_doc(doc, bib, filename, glob_idx = nil)
        amsid = doc.publicationinfo.amsid
        if backrefs.value?(bib.docidentifier[0].content) && /updates\.\d+/ !~ filename
          oamsid = backrefs.key bib.docidentifier[0].content
          Util.warn "Document exists ID: `#{bib.docidentifier[0].content}` AMSID: " \
              "`#{amsid}` source: `#{filename}`. Other AMSID: `#{oamsid}`"
          if bib.docidentifier.find(&:primary).content.include?(doc.publicationinfo.stdnumber)
            save_doc(bib, glob_idx) # rewrite file if the PubID matches to the stdnumber
            backrefs[amsid] = bib.docidentifier[0].content
            track_save(bib.docnumber, glob_idx)
          end
        else
          save_doc(bib, glob_idx)
          backrefs[amsid] = bib.docidentifier[0].content
          track_save(bib.docnumber, glob_idx)
        end
      end

      #
      # Record that we wrote a staged copy of `docnumber` at this
      # `glob_idx`. The parent later picks the highest tracked idx
      # per docnumber as the surviving on-disk version.
      #
      def track_save(docnumber, glob_idx)
        return unless glob_idx

        prev = saved_writes[docnumber]
        saved_writes[docnumber] = glob_idx if prev.nil? || glob_idx > prev
      end

      #
      # Save document to file. When `glob_idx` is provided (parallel
      # mode), writes to a per-glob-index suffixed staging path so
      # concurrent workers can't clobber each other's files; the parent
      # reconciles after parsing. With no glob_idx, writes the final
      # filename directly (sequential mode and update_relations).
      #
      # @param [RelatonIeee::IeeeBibliographicItem] bib
      # @param [Integer, nil] glob_idx position in the original file glob
      #
      def save_doc(bib, glob_idx = nil)
        path = output_file(bib.docnumber)
        path = "#{path}.#{glob_idx}" if glob_idx
        File.write path, serialize(bib), encoding: "UTF-8"
      end

      def to_yaml(bib) = bib.to_yaml
      def to_xml(bib) = bib.to_xml(bibdata: true)
      def to_bibxml(bib) = bib.to_rfcxml

      #
      # Resolve cross-references collected during parse. Uses the in-memory
      # `docs` cache so we don't re-read+re-deserialize files from disk, and
      # writes each mutated bib once instead of once per relation.
      #
      def update_relations # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        crossrefs.each do |dnum, rfs|
          bib = nil
          mutated = false
          rfs.each do |rf|
            if backrefs[rf[:amsid]]
              rel = create_relation(rf[:type], backrefs[rf[:amsid]])
              if rel
                bib ||= docs[dnum] || read_bib(dnum)
                bib.relation << rel
                mutated = true
              end
            else
              Util.warn "Unresolved relation: '#{rf[:amsid]}' type: '#{rf[:type]}' for '#{dnum}'"
            end
          end
          save_doc(bib) if mutated
        end
      end

      #
      # Read document form BibXML/BibYAML file
      #
      # @param [String] docnumber
      #
      # @return [RelatonIeee::IeeeBibliographicItem]
      #
      def read_bib(docnumber)
        c = File.read output_file(docnumber), encoding: "UTF-8"
        case @format
        when "xml" then Item.from_xml c
        when "bibxml" then Converter::BibXml.to_item c
        else Item.from_yaml c
        end
      end
    end
  end
end
