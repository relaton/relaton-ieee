module RelatonIeee
  module BibXMLParser
    extend RelatonBib::BibXMLParser
    extend BibXMLParser

    # @param attrs [Hash]
    # @return [RelatonBib::IetfBibliographicItem]
    def bib_item(**attrs)
      IeeeBibliographicItem.new(**attrs)
    end

    #
    # Return PubID type
    #
    # @param [String] _ docidentifier
    #
    # @return [String] type
    #
    def pubid_type(_)
      "IEEE"
    end
  end
end
