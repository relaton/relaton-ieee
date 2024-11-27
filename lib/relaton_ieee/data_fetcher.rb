require "zip"
require "relaton_ieee/idams_parser"
require "relaton_ieee/rawbib_id_parser"

module RelatonIeee
  class DataFetcher
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

    # @return [Hash] list of AMSID => PubID
    attr_reader :backrefs

    #
    # Create RelatonIeee::DataFetcher instance
    #
    # @param [String] output output dir
    # @param [Strong] format output format. Allowed values: "yaml" or "xml"
    #
    def initialize(output, format)
      @output = output
      @format = format
      @ext = format.sub(/^bib/, "")
      @crossrefs = {}
      @backrefs = {}
    end

    #
    # Convert documents from `ieee-rawbib` dir (IEEE dataset) to BibYAML/BibXML
    #
    # @param [String] output ('data') output dir
    # @param [String] format ('yaml') output format.
    #   Allowed values: "yaml" or "xml"
    #
    def self.fetch(output: "data", format: "yaml")
      t1 = Time.now
      puts "Started at: #{t1}"
      FileUtils.mkdir_p output
      new(output, format).fetch
      t2 = Time.now
      puts "Stopped at: #{t2}"
      puts "Done in: #{(t2 - t1).round} sec."
    end

    #
    # Convert documents from `ieee-rawbib` dir (IEEE dataset) to BibYAML/BibXML
    #
    def fetch # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      Dir["ieee-rawbib/**/*.{xml,zip}"].reject { |f| f["Deleted_"] }.each do |f|
        xml = case File.extname(f)
              when ".zip" then read_zip f
              when ".xml" then File.read f, encoding: "UTF-8"
              end
        fetch_doc xml, f
      rescue StandardError => e
        Util.error "File: #{f}\n#{e.message}\n#{e.backtrace}"
      end
      # File.write "normtitles.txt", @normtitles.join("\n")
      update_relations
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
    # Parse document and save it
    #
    # @param [String] xml content
    # @param [String] filename source file
    #
    def fetch_doc(xml, filename) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      begin
        doc = Ieee::Idams::Publication.from_xml(xml)
      rescue StandardError
        Util.warn "Empty file: `#{filename}`"
        return
      end
      return if doc.publicationinfo&.standard_id == "0"

      bib = IdamsParser.new(doc, self).parse
      if bib.docnumber.nil?
        Util.warn "PubID parse error. Normtitle: `#{doc.normtitle}`, file: `#{filename}`"
        return
      end
      amsid = doc.publicationinfo.amsid
      if backrefs.value?(bib.docidentifier[0].id) && /updates\.\d+/ !~ filename
        oamsid = backrefs.key bib.docidentifier[0].id
        Util.warn "Document exists ID: `#{bib.docidentifier[0].id}` AMSID: " \
             "`#{amsid}` source: `#{filename}`. Other AMSID: `#{oamsid}`"
        if bib.docidentifier.find(&:primary).id.include?(doc.publicationinfo.stdnumber)
          save_doc bib # rewrite file if the PubID matches to the stdnumber
          backrefs[amsid] = bib.docidentifier[0].id
        end
      else
        save_doc bib
        backrefs[amsid] = bib.docidentifier[0].id
      end
    end

    #
    # Save unresolved relation reference
    #
    # @param [String] docnumber of main document
    # @param [Nokogiri::XML::Element] amsid relation data
    #
    def add_crossref(docnumber, amsid)
      return if RELATION_TYPES[amsid.type] == false

      ref = { amsid: amsid.date_string, type: amsid.type }
      if @crossrefs[docnumber]
        @crossrefs[docnumber] << ref
      else @crossrefs[docnumber] = [ref]
      end
    end

    #
    # Save document to file
    #
    # @param [RelatonIeee::IeeeBibliographicItem] bib
    #
    def save_doc(bib)
      c = case @format
          when "xml" then bib.to_xml(bibdata: true)
          when "yaml" then bib.to_hash.to_yaml
          else bib.send("to_#{@format}")
          end
      File.write file_name(bib.docnumber), c, encoding: "UTF-8"
    end

    #
    # Make filename from PubID
    #
    # @param [String] docnumber
    #
    # @return [String] filename
    #
    def file_name(docnumber)
      name = docnumber.gsub(/\s-/, "-").gsub(/[\s,:\/]/, "_").squeeze("_").upcase
      File.join @output, "#{name}.#{@ext}"
    end

    #
    # Update unresoverd relations
    #
    def update_relations # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      @crossrefs.each do |dnum, rfs|
        bib = nil
        rfs.each do |rf|
          if backrefs[rf[:amsid]]
            rel = create_relation(rf[:type], backrefs[rf[:amsid]])
            if rel
              bib ||= read_bib(dnum)
              bib.relation << rel
              save_doc bib
            end
          else
            Util.warn "Unresolved relation: '#{rf[:amsid]}' type: '#{rf[:type]}' for '#{dnum}'"
          end
        end
      end
    end

    #
    # Create relation instance
    #
    # @param [String] type IEEE relation type
    # @param [String] fref reference
    #
    # @return [RelatonBib::DocumentRelation]
    #
    def create_relation(type, fref) # rubocop:disable Metrics/MethodLength
      return if RELATION_TYPES[type] == false

      fr = RelatonBib::FormattedRef.new(content: fref)
      docid = RelatonBib::DocumentIdentifier.new(type: "IEEE", id: fref, primary: true)
      bib = IeeeBibliographicItem.new formattedref: fr, docid: [docid]
      desc = RELATION_TYPES[type][:description]
      description = desc && RelatonBib::FormattedString.new(content: desc, language: "en", script: "Latn")
      RelatonBib::DocumentRelation.new(
        type: RELATION_TYPES[type][:type],
        description: description,
        bibitem: bib,
      )
    end

    #
    # Read document form BibXML/BibYAML file
    #
    # @param [String] docnumber
    #
    # @return [RelatonIeee::IeeeBibliographicItem]
    #
    def read_bib(docnumber)
      c = File.read file_name(docnumber), encoding: "UTF-8"
      case @format
      when "xml" then XMLParser.from_xml c
      when "bibxml" then BibXMLParser.parse c
      else IeeeBibliographicItem.from_hash YAML.safe_load(c)
      end
    end
  end
end
