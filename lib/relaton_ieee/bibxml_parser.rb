module RelatonIeee
  module BibXMLParser
    extend RelatonBib::BibXMLParser
    extend BibXMLParser

    FLAVOR = "IEEE"

    # @param attrs [Hash]
    # @return [RelatonBib::IetfBibliographicItem]
    def bib_item(**attrs)
      IeeeBibliographicItem.new(**attrs)
    end
  end
end