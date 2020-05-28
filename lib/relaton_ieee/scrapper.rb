module RelatonIeee
  module Scrapper
    class << self
      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize

      # papam hit [Hash]
      # @return [RelatonOgc::OrcBibliographicItem]
      def parse_page(hit)
        doc = Nokogiri::HTML Faraday.get(hit["recordURL"]).body
        IeeeBibliographicItem.new(
          fetched: Date.today.to_s,
          title: fetch_title(hit["recordTitle"]),
          docid: fetch_docid(hit["recordTitle"]),
          link: fetch_link(hit["recordURL"]),
          docstatus: fetch_status(doc),
          abstract: fetch_abstract(doc),
          contributor: fetch_contributor(doc),
          language: ["en"],
          script: ["Latn"],
          date: fetch_date(doc),
          committee: fetch_committee(doc),
        )
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      private

      # @param title [String]
      # @return [Array<RelatonBib::TypedTitleString>]
      def fetch_title(title)
        [
          RelatonBib::TypedTitleString.new(
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

        RelatonBib::DocumentStatus.new(stage: stage.text)
      end

      # @param identifier [String]
      # @return [String]
      # def fetch_edition(identifier)
      #   %r{(?<=r)(?<edition>\d+)$} =~ identifier
      #   edition
      # end

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
        name = doc.at(
          "//td[.='IEEE Program Manager']/following-sibling::td/div/a",
        )
        return [] unless name

        [personn_contrib(name.text)]
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
      # def org_contrib(name)
      #   entity = RelatonBib::Organization.new(name: name)
      #   RelatonBib::ContributionInfo.new(
      #     entity: entity, role: [type: "publisher"],
      #   )
      # end

      # rubocop:disable Metrics/MethodLength

      # @param date [Nokogiri::HTML::Document]
      # @return [Array<RelatonBib::BibliographicDate>]
      def fetch_date(doc)
        dates = []
        issued = doc.at "//td[.='Board Approval']/following-sibling::td/div"
        if issued
          dates << RelatonBib::BibliographicDate.new(type: "issued",
                                                     on: issued.text)
        end
        published = doc.at("//td[.='History']/following-sibling::td/div")&.
          text&.match(/(?<=Published Date:)[\d-]+/)&.to_s
        if published
          dates << RelatonBib::BibliographicDate.new(type: "published",
                                                     on: published)
        end
        dates
      end
      # rubocop:enable Metrics/MethodLength

      # @param doc [Nokogiri::HTML::Document]
      # @return [Array<RelatonIeee::Committee>]
      def fetch_committee(doc)
        committees = []
        sponsor = doc.at "//td[.='Sponsor Committee']/following-sibling::td/div"
        if sponsor
          committees << Committee.new(type: "sponsor", name: sponsor.text)
        end
        working = doc.at "//td[.='Working Group']/following-sibling::td/div"
        chair = doc.at "//td[.='Working Group Chair']/following-sibling::td/div"
        if working
          committees << Committee.new(type: "working", name: working.text,
                                      chair: chair.text)
        end
        society = doc.at "//td[.='Society']/following-sibling::td/div"
        if society
          committees << Committee.new(type: "society", name: society.text)
        end
        committees
      end
    end
  end
end
