module RelatonIeee
  class IeeeBibliographicItem < RelatonBib::BibliographicItem
    # @return [Array<RelatonIeee::Committee>]
    attr_reader :committee

    # @param committee [Array<RelatonIeee::Committee>]
    def initialize(**args)
      @committee = args.delete :committee
      super
    end

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [Boolean] :bibdata
    # @option opts [String] :lang language
    # @return [String] XML
    def to_xml(**opts)
      super **opts do |bldr|
        if opts[:bibdata] && committee.any?
          bldr.ext do |b|
            committee.each { |c| c.to_xml b }
          end
        end
      end
    end

    # @return [Hash]
    def to_hash
      hash = super
      hash["committee"] = committee.map &:to_hash
      hash
    end

    # @param prefix [String]
    # @return [String]
    def to_asciibib(prefix = "")
      out = super
      committee.each { |c| out += c.to_asciibib prefix, committee.size }
      out
    end
  end
end
