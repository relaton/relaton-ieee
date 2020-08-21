module RelatonIeee
  class IeeeBibliographicItem < RelatonBib::BibliographicItem
    # @return [Array<RelatonIeee::Committee>]
    attr_reader :committee

    # @param committee [Array<RelatonIeee::Committee>]
    def initialize(**args)
      @committee = args.delete :committee
      super
    end

    # @param builder [Nokogiri::XML::Bilder]
    # @parma bibdata [TrueClass, FalseClass, NilClass]
    def to_xml(builder = nil, **opts)
      super do |bldr|
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
