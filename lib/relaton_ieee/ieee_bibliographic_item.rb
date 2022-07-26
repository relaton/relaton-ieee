module RelatonIeee
  class IeeeBibliographicItem < RelatonBib::BibliographicItem
    TYPES = %w[guide recommended-practice standard].freeze
    SUBTYPES = %w[amendment corrigendum erratum].freeze

    # @return [RelatonIeee::EditorialGroup, nil]
    attr_reader :editorialgroup

    # @return [Boolean, nil] Trial use
    attr_reader :trialuse

    #
    # @param [Hash] args
    # @option args [Boolean, nil] :trialuse Trial use
    # @option args [Array<RelatonIeee::EditorialGroup>] :editorialgroup Editorial group
    #
    def initialize(**args)
      if args[:doctype] && !TYPES.include?(args[:doctype])
        warn "[relaton-ieee] doctype should be one of #{TYPES.join(', ')}"
      end
      if args[:docsubtype] && !SUBTYPES.include?(args[:docsubtype])
        warn "[relaton-ieee] docsubtype should be one of #{SUBTYPES.join(', ')}"
      end
      eg = args.delete(:editorialgroup)
      @trialuse = args.delete(:trialuse)
      super
      @editorialgroup = eg
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
        if opts[:bibdata] && (doctype || subdoctype || !trialuse.nil? || editorialgroup || ics.any?)
          bldr.ext do |b|
            b.doctype doctype if doctype
            b.subdoctype subdoctype if subdoctype
            b.send :"trial-use", trialuse unless trialuse.nil?
            editorialgroup&.to_xml(b)
            ics.each { |ic| ic.to_xml(b) }
          end
        end
      end
    end

    # @return [Hash]
    def to_hash
      hash = super
      hash["trialuse"] = trialuse unless trialuse.nil?
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
