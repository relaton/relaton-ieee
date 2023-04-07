module RelatonIeee
  class IeeeBibliographicItem < RelatonBib::BibliographicItem
    DOCTYPES = %w[guide recommended-practice standard witepaper redline other].freeze
    SUBTYPES = %w[amendment corrigendum erratum].freeze

    # @return [RelatonIeee::EditorialGroup, nil]
    attr_reader :editorialgroup

    # @return [Boolean, nil] Trial use
    attr_reader :trialuse

    # @return [String, nil]
    attr_reader :standard_status, :standard_modifier, :pubstatus, :holdstatus

    #
    # @param [Hash] args
    # @option args [Boolean, nil] :trialuse Trial use
    # @option args [Array<RelatonIeee::EditorialGroup>] :editorialgroup
    #   Editorial group
    # @option args [String, nil] :standard_status Active, Inactive, Superseded
    # @option args [String, nil] :standard_modifier Draft, Withdrawn, Suspended,
    #   Approved, Reserved, Redline
    # @option args [String, nil] :pubstatus Active, Inactive
    # @option args [String, nil] :holdstatus Held, Publish
    #
    def initialize(**args) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      if args[:doctype] && !DOCTYPES.include?(args[:doctype])
        warn "[relaton-ieee] invalid doctype \"#{args[:doctype]}\". " \
             "It should be one of: #{DOCTYPES.join(', ')}."
      end
      if args[:docsubtype] && !SUBTYPES.include?(args[:docsubtype])
        warn "[relaton-ieee] invalid docsubtype \"#{args[:docsubtype]}\". " \
             "It should be one of: #{SUBTYPES.join(', ')}."
      end
      eg = args.delete(:editorialgroup)
      @trialuse = args.delete(:trialuse)
      @standard_status = args.delete(:standard_status)
      @standard_modifier = args.delete(:standard_modifier)
      @pubstatus = args.delete(:pubstatus)
      @holdstatus = args.delete(:holdstatus)
      super
      @editorialgroup = eg
    end

    #
    # Fetch flavor schema version
    #
    # @return [String] flavor schema version
    #
    def ext_schema
      @ext_schema ||= schema_versions["relaton-model-ieee"]
    end

    # @param hash [Hash]
    # @return [RelatonIeee::IeeeBibliographicItem]
    def self.from_hash(hash)
      item_hash = ::RelatonIeee::HashConverter.hash_to_bib(hash)
      new(**item_hash)
    end

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [Boolean] :bibdata
    # @option opts [String] :lang language
    # @return [String] XML
    def to_xml(**opts) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      super(**opts) do |bldr|
        if opts[:bibdata] && (doctype || subdoctype || !trialuse.nil? || editorialgroup ||
           ics.any? || standard_status || standard_modifier || pubstatus || holdstatus)
          ext = bldr.ext do |b|
            b.doctype doctype if doctype
            b.subdoctype subdoctype if subdoctype
            b.send :"trial-use", trialuse unless trialuse.nil?
            editorialgroup&.to_xml(b)
            ics.each { |ic| ic.to_xml(b) }
            b.standard_status standard_status if standard_status
            b.standard_modifier standard_modifier if standard_modifier
            b.pubstatus pubstatus if pubstatus
            b.holdstatus holdstatus if holdstatus
          end
          ext["schema-version"] = ext_schema unless opts[:embedded]
        end
      end
    end

    #
    # Rnder as Hash
    #
    # @param embedded [Boolean] emmbedded in other document
    #
    # @return [Hash]
    #
    def to_hash(embedded: false) # rubocop:disable Metrics/AbcSize
      hash = super
      hash["trialuse"] = trialuse unless trialuse.nil?
      hash["ext"]["standard_status"] = standard_status unless standard_status.nil?
      hash["ext"]["standard_modifier"] = standard_modifier unless standard_modifier.nil?
      hash["ext"]["pubstatus"] = pubstatus unless pubstatus.nil?
      hash["ext"]["holdstatus"] = holdstatus unless holdstatus.nil?
      hash
    end

    # @param prefix [String]
    # @return [String]
    def to_asciibib(prefix = "")
      out = super
      out += "#{prefix}.trialuse:: #{trialuse}\n" unless trialuse.nil?
      out
    end
  end
end
