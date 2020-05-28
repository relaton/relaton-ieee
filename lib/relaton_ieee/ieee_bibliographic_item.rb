module RelatonIeee
  class IeeeBibliographicItem < RelatonBib::BibliographicItem
    # @return [Array<RelatonIeee::Committee>]
    attr_reader :committee

    # @param committee [Array<RelatonIeee::Committee>]
    def initialize(**args)
      @committee = args.delete :committee
      super
    end

    def to_xml(builder = nil, **opts)
      super do |bldr|
        if committee.any?
          bldr.ext do |b|
            committee.each { |c| c.to_xml b }
          end
        end
      end
    end
  end
end
