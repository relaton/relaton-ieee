module RelatonIeee
  module Scrapper
    class << self
      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize

      # papam hit [Hash]
      # @return [RelatonOgc::OrcBibliographicItem]
      def parse_page(hit)
        doc = Nokogiri::HTML Faraday.get(hit[:url]).body
        IeeeBibliographicItem.new(
          fetched: Date.today.to_s,
          title: fetch_title(doc),
          docid: fetch_docid(hit[:ref]),
          link: fetch_link(hit[:url]),
          docstatus: fetch_status(doc),
          abstract: fetch_abstract(doc),
          contributor: fetch_contributor(doc),
          language: ["en"],
          script: ["Latn"],
          date: fetch_date(doc),
          committee: fetch_committee(doc),
          place: ["Piscataway, NJ, USA"],
        )
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      private

      # @param doc [String] Nokogiri::HTML4::Document
      # @return [Array<RelatonBib::TypedTitleString>]
      def fetch_title(doc)
        doc.xpath("//h2[@id='stnd-title']").map do |t|
          RelatonBib::TypedTitleString.new(
            type: "main", content: t.text, language: "en", script: "Latn",
          )
        end
      end

      # @param ref [String]
      # @return [Array<RelatonBib::DocumentIdentifier>]
      def fetch_docid(ref)
        args = { id: ref, type: "IEEE", primary: true }
        ids = [RelatonBib::DocumentIdentifier.new(**args)]
        args[:scope] = "trademark"
        tm = ref.match?(/^IEEE\s(Std\s)?(802|2030)/) ? "\u00AE" : "\u2122"
        args[:id] = ref.sub(/^(IEEE\s(?:Std\s)?[.\w]+)/) { |s| "#{s}#{tm}" }
        ids << RelatonBib::DocumentIdentifier.new(**args)
      end

      # @param url [String]
      # @return [Array>RelatonBib::TypedUri>]
      def fetch_link(url)
        [RelatonBib::TypedUri.new(type: "src", content: url)]
      end

      # @param doc [Nokogiri::HTML::Document]
      # @return [RelatonBib::DocumentStatus, NilClass]
      def fetch_status(doc)
        stage = doc.at("//dd[@id='stnd-status']")
        return unless stage

        RelatonBib::DocumentStatus.new(stage: stage.text.split.first)
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
        doc.xpath("//div[@id='stnd-description']").map do |a|
          RelatonBib::FormattedString.new(
            content: a.text.strip, language: "en", script: "Latn",
          )
        end
      end

      # @param doc [Nokogiri::HTML::Document]
      # @return [Array<RelatonBib::ContributionInfo>]
      def fetch_contributor(doc) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        address = RelatonBib::Address.new(
          street: ["445 Hoes Lane"], postcode: "08854-4141", city: "Piscataway",
          state: "NJ", country: "USA"
        )
        org = RelatonBib::Organization.new(
          name: "Institute of Electrical and Electronics Engineers",
          abbreviation: "IEEE", contact: [address]
        )
        contrib = RelatonBib::ContributionInfo.new(entity: org, role: [type: "publisher"])
        doc.xpath("//dd[@id='stnd-staff-liaison']/text()").map do |name|
          person_contrib(name.text.strip)
        end << contrib
      end

      # @param name [String]
      # @return [RelatonBib::ContributionInfo]
      def person_contrib(name)
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
        id = doc.at "//dd[@id='stnd-approval-date']"
        if id
          dates << RelatonBib::BibliographicDate.new(type: "issued", on: id.text)
        end
        pd = doc.at("//dd[@id='stnd-published-date']")
        if pd
          dates << RelatonBib::BibliographicDate.new(type: "published", on: pd.text)
        end
        dates
      end

      # rubocop:disable Metrics/AbcSize

      # @param doc [Nokogiri::HTML::Document]
      # @return [Array<RelatonIeee::Committee>]
      def fetch_committee(doc)
        committees = []
        sponsor = doc.at "//dd[@id='stnd-committee']/text()"
        if sponsor
          committees << Committee.new(type: "sponsor", name: sponsor.text.strip)
        end
        sponsor = doc.at "//td[.='Standards Committee']/following-sibling::td/div/a"
        if sponsor
          committees << Committee.new(type: "standard", name: sponsor.text)
        end
        working = doc.at "//dd[@id='stnd-working-group']/text()"
        if working
          chair = doc.at "//dd[@id='stnd-working-group-chair']"
          committees << Committee.new(type: "working", name: working.text.strip,
                                      chair: chair.text)
        end
        society = doc.at "//dd[@id='stnd-society']/text()"
        if society
          committees << Committee.new(type: "society", name: society.text.strip)
        end
        committees
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
    end
  end
end
