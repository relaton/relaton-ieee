module RelatonIeee
  class XMLParser < RelatonBib::XMLParser
    class << self
      private

      # Override RelatonBib::XMLParser.item_data method.
      # @param item [Nokogiri::XML::Element]
      # @returtn [Hash]
      def item_data(item)
        data = super
        ext = item.at "./ext"
        return data unless ext

        data[:committee] = ext.xpath("./committee").map do |c|
          Committee.new(
            type: c[:type], name: c.at("name").text, chair: c.at("chair")&.text
          )
        end
        data
      end

      # @param item_hash [Hash]
      # @return [RelatonIeee::IeeeBibliographicItem]
      def bib_item(item_hash)
        IeeeBibliographicItem.new **item_hash
      end
    end
  end
end
