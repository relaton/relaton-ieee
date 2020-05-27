module RelatonIeee
  class Hit < RelatonBib::Hit
    # Parse page.
    # @return [RelatonIeee::IeeeBliographicItem]
    def fetch
      @fetch ||= Scrapper.parse_page @hit
    end
  end
end
