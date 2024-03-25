module RelatonIeee
  class XMLParser < RelatonBib::XMLParser
    class << self
      private

      # Override RelatonBib::XMLParser.item_data method.
      # @param item [Nokogiri::XML::Element]
      # @returtn [Hash]
      def item_data(item) # rubocop:disable Metrics/AbcSize
        data = super
        ext = item.at "./ext"
        return data unless ext

        data[:editorialgroup] = parse_editorialgroup(item)
        data[:standard_status] = ext.at("./standard_status")&.text
        data[:standard_modified] = ext.at("./standard_modified")&.text
        data[:pubstatus] = ext.at("./pubstatus")&.text
        data[:holdstatus] = ext.at("./holdstatus")&.text
        data
      end

      # @param item_hash [Hash]
      # @return [RelatonIeee::IeeeBibliographicItem]
      def bib_item(item_hash)
        IeeeBibliographicItem.new(**item_hash)
      end

      #
      # Parse editorialgroup
      #
      # @param [Nokogiri::XML::Element] item XML element
      #
      # @return [RelatonIeee::EditorialGroup] Editorial group
      #
      def parse_editorialgroup(item)
        eg = item.at "./ext/editorialgroup"
        return unless eg

        society = eg.at("./society")&.text
        bg = parse_balloting_group(eg)
        wg = eg.at("./working-group")&.text
        committee = eg.xpath("./committee").map(&:text)
        EditorialGroup.new(society: society, balloting_group: bg,
                           working_group: wg, committee: committee)
      end

      #
      # Parse balloting group
      #
      # @param [Nokogiri::XML::Element] editorialgroup XML element
      #
      # @return [RelatonIeee::BallotingGroup] Balloting group
      #
      def parse_balloting_group(editorialgroup)
        bg = editorialgroup.at("./balloting-group")
        return unless bg

        BallotingGroup.new type: bg[:type], content: bg.text
      end

      def create_doctype(type)
        DocumentType.new type: type.text, abbreviation: type[:abbreviation]
      end
    end
  end
end
