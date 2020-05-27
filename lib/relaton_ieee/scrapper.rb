module RelatonIeee
  module Scrapper
    class << self
      # papam hit [Hash]
      # @return [RelatonOgc::OrcBibliographicItem]
      def parse_page(hit)
        doc = Nokogiri::HTML Faraday.get(hit["recordURL"]).body
        RelatonBib::BibliographicItem.new(
          fetched: Date.today.to_s,
          title: fetch_title(hit["recordTitle"]),
          docid: fetch_docid(hit["recordTitle"]),
          link: fetch_link(hit["recordURL"]),
          # doctype: type[:type],
          # docsubtype: type[:subtype],
          docstatus: fetch_status(doc),
          # edition: fetch_edition(hit["identifier"]),
          abstract: fetch_abstract(doc),
          contributor: fetch_contributor(doc),
          language: ["en"],
          script: ["Latn"],
          date: fetch_date(hit["date"]),
          # editorialgroup: fetch_editorialgroup,
        )
      end

      private

      # def fetch_editorialgroup
      #   EditorialGroup.new committee: "technical"
      # end

      # @param title [String]
      # @return [Array<RelatonIsoBib::TypedTitleString>]
      def fetch_title(title)
        [
          RelatonIsoBib::TypedTitleString.new(
            type: "main", content: title, language: "en", script: "Latn",
          ),
        ]
      end

      # @param title [String]
      # @return [Array<RelatonBib::DocumentIdentifier>]
      def fetch_docid(title)
        /^(?<identifier>\S+)/ =~ title
        [RelatonBib::DocumentIdentifier.new(id: identifier, type: "IEEE")]
      end

      # @param url [String]
      # @return [Array>RelatonBib::TypedUri>]
      def fetch_link(url)
        [RelatonBib::TypedUri.new(type: "src", content: url)]
      end

      # @param doc [Nokogiri::HTML::Document]
      # @return [RelatonBib::DocumentStatus, NilClass]
      def fetch_status(doc)
        stage = doc.at("//td[.='Status']/following-sibling::td/div")
        return unless stage

        RelatonBib::DocunentStatus.new(stage: stage)
      end

      # @param identifier [String]
      # @return [String]
      def fetch_edition(identifier)
        %r{(?<=r)(?<edition>\d+)$} =~ identifier
        edition
      end

      # @param doc [Nokogiri::HTML::Document]
      # @return [Array<RelatonBib::FormattedString>]
      def fetch_abstract(doc)
        content = doc.at("//div[@class='description']")
        return [] unless content

        [RelatonBib::FormattedString.new(content: content.text, language: "en",
                                         script: "Latn")]
      end

      # @param doc [Nokogiri::HTML::Document]
      # @return [Array<RelatonBib::ContributionInfo>]
      def fetch_contributor(doc)
        contribs = doc["creator"].to_s.split(", ").map do |name|
          personn_contrib name
        end
        contribs << org_contrib(doc["publisher"]) if doc["publisher"]
      end

      # @param name [String]
      # @return [RelatonBib::ContributionInfo]
      def personn_contrib(name)
        fname = RelatonBib::FullName.new(
          completename: RelatonBib::LocalizedString.new(name),
        )
        entity = RelatonBib::Person.new(name: fname)
        RelatonBib::ContributionInfo.new(
          entity: entity, role: [type: "author"],
        )
      end

      # @param name [String]
      # @return [RelatonBib::ContributionInfo]
      def org_contrib(name)
        entity = RelatonBib::Organization.new(name: name)
        RelatonBib::ContributionInfo.new(
          entity: entity, role: [type: "publisher"],
        )
      end

      # @param date [String]
      # @return [Array<RelatonBib::BibliographicDate>]
      def fetch_date(date)
        [RelatonBib::BibliographicDate.new(type: "published", on: date)]
      end
    end
  end
end
