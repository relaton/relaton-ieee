require_relative "renderer/bibxml"

module RelatonIeee
  class IeeeBibliographicItem < RelatonBib::BibliographicItem
    SUBTYPES = %w[amendment corrigendum erratum].freeze

    # @return [RelatonIeee::EditorialGroup, nil]
    attr_reader :editorialgroup

    # @return [Boolean, nil] Trial use
    attr_reader :trialuse

    # @return [String, nil]
    attr_reader :standard_status, :standard_modified, :pubstatus, :holdstatus

    #
    # @param [Hash] args
    # @option args [Boolean, nil] :trialuse Trial use
    # @option args [Array<RelatonIeee::EditorialGroup>] :editorialgroup
    #   Editorial group
    # @option args [String, nil] :standard_status Active, Inactive, Superseded
    # @option args [String, nil] :standard_modified Draft, Withdrawn, Suspended,
    #   Approved, Reserved, Redline
    # @option args [String, nil] :pubstatus Active, Inactive
    # @option args [String, nil] :holdstatus Held, Publish
    #
    def initialize(**args) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      if args[:docsubtype] && !SUBTYPES.include?(args[:docsubtype])
        Util.warn "Invalid docsubtype: `#{args[:docsubtype]}`. " \
                  "It should be one of: `#{SUBTYPES.join('`, `')}`."
      end
      eg = args.delete(:editorialgroup)
      @trialuse = args.delete(:trialuse)
      @standard_status = args.delete(:standard_status)
      @standard_modified = args.delete(:standard_modified)
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
           ics.any? || standard_status || standard_modified || pubstatus || holdstatus)
          ext = bldr.ext do |b|
            doctype&.to_xml b
            b.subdoctype subdoctype if subdoctype
            b.send :"trial-use", trialuse unless trialuse.nil?
            editorialgroup&.to_xml(b)
            ics.each { |ic| ic.to_xml(b) }
            b.standard_status standard_status if standard_status
            b.standard_modified standard_modified if standard_modified
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
      hash["ext"]["trialuse"] = trialuse unless trialuse.nil?
      hash["ext"]["standard_status"] = standard_status unless standard_status.nil?
      hash["ext"]["standard_modified"] = standard_modified unless standard_modified.nil?
      hash["ext"]["pubstatus"] = pubstatus unless pubstatus.nil?
      hash["ext"]["holdstatus"] = holdstatus unless holdstatus.nil?
      hash
    end

    def has_ext?
      super || !trialuse.nil? || standard_status || standard_modified || pubstatus || holdstatus
    end

    # @param prefix [String]
    # @return [String]
    def to_asciibib(prefix = "")
      out = super
      out += "#{prefix}.trialuse:: #{trialuse}\n" unless trialuse.nil?
      out
    end

    #
    # Render BibXML (RFC)
    #
    # @param [Nokogiri::XML::Builder, nil] builder
    # @param [Boolean] include_keywords (false)
    #
    # @return [String, Nokogiri::XML::Builder::NodeBuilder] XML
    #
    def to_bibxml(builder = nil, include_keywords: false)
      Renderer::BibXML.new(self).render builder: builder, include_keywords: include_keywords
    end
  end
end
