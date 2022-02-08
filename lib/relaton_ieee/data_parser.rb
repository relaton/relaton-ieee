module RelatonIeee
  class DataParser
    DATETYPES = { "OriginalPub" => "created", "ePub" => "published",
                  "LastInspecUpd" => "updated" }.freeze

    attr_reader :doc, :fetcher

    #
    # Create RelatonIeee::DataParser instance
    #
    # @param [Nokogiri::XML::Element] doc document
    # @param [RelatonIeee::DataFetcher] fetcher
    #
    def initialize(doc, fetcher)
      @doc = doc
      @fetcher = fetcher
    end

    #
    # Parse IEEE document
    #
    # @param [Nokogiri::XML::Element] doc document
    # @param [RelatonIeee::DataFetcher] fetcher <description>
    #
    # @return [RelatonIeee::IeeeBibliographicItem]
    #
    def self.parse(doc, fetcher)
      new(doc, fetcher).parse
    end

    #
    # Parse IEEE document
    #
    # @return [RelatonIeee::IeeeBibliographicItem]
    #
    def parse # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      args = {
        type: "standard",
        docnumber: docnumber,
        title: parse_title,
        date: parse_date,
        docid: parse_docid,
        contributor: parse_contributor,
        abstract: parse_abstract,
        copyright: parse_copyright,
        language: ["en"],
        script: ["Latn"],
        status: parse_status,
        relation: parse_relation,
        link: parse_link,
        keyword: parse_keyword,
        ics: parse_ics,
      }
      IeeeBibliographicItem.new(**args)
    end

    #
    # Parse title
    #
    # @return [Array<RelatonBib::TypedTitleString>]
    #
    def parse_title
      t = []
      content = doc.at("./volume/article/title").text
      if content =~ /\A(.+)\s-\sredline\z/i
        t << RelatonBib::TypedTitleString.new(content: $1, type: "title-main")
      end
      t << RelatonBib::TypedTitleString.new(content: content, type: "main")
    end

    #
    # Parse date
    #
    # @return [Array<RelatonBib::BibliographicDate>]
    #
    def parse_date # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength
      dates = doc.xpath("./volume/article/articleinfo/date").map do |d|
        da = [d.at("./year").text]
        m = d.at("./month")&.text
        if m
          month = Date::ABBR_MONTHNAMES.index(m.sub(/\./, "")) || m
          da << month.to_s.rjust(2, "0")
        end
        day = d.at("./day")
        da << day.text.rjust(2, "0") if day
        on = da.compact.join "-"
        RelatonBib::BibliographicDate.new type: DATETYPES[d[:datetype]], on: on
      end
      pad = doc.at("./publicationinfo/PubApprovalDate")
      if pad
        issued = parse_date_string pad.text
        dates << RelatonBib::BibliographicDate.new(type: "issued", on: issued)
      end
      dates
    end

    #
    # Convert date string with month name to numeric date
    #
    # @param [String] date source date
    #
    # @return [String] numeric date
    #
    def parse_date_string(date)
      case date
      when /^\d{4}$/ then date
      when /^\d{1,2}\s\w+\.?\s\d{4}/ then Date.parse(date).to_s
      end
    end

    #
    # Parse identifiers
    #
    # @return [Array<RelatonBib::DocumentIdentifier>]
    #
    def parse_docid
      ids = [{ id: pubid.to_s, type: "IEEE", primary: true }]
      isbn = doc.at("./publicationinfo/isbn")
      ids << { id: isbn.text, type: "ISBN" } if isbn
      doi = doc.at("./volume/article/articleinfo/articledoi")
      ids << { id: doi.text, type: "DOI" } if doi
      ids.map do |dcid|
        RelatonBib::DocumentIdentifier.new(**dcid)
      end
    end

    def pubid
      @pubid ||= begin
        nt = doc.at("./normtitle").text
        RawbibIdParser.parse(nt)
      end
    end

    #
    # Parse docnumber
    #
    # @return [String] PubID
    #
    def docnumber
      @docnumber ||= pubid&.to_id # doc.at("./publicationinfo/stdnumber").text
    end

    #
    # Parse contributors
    #
    # @return [Array<RelatonBib::ContributionInfo>]
    #
    def parse_contributor # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      doc.xpath("./publicationinfo/publisher").map do |contrib|
        n = contrib.at("./publishername").text
        addr = contrib.xpath("./address").map do |a|
          RelatonBib::Address.new(
            street: [],
            city: a.at("./city")&.text,
            country: a.at("./country").text,
          )
        end
        e = create_org n, addr
        RelatonBib::ContributionInfo.new entity: e, role: [type: "publisher"]
      end
    end

    #
    # Create organization
    #
    # @param [String] name organization's name
    # @param [Array<Hash>] addr address
    #
    # @return [RelatonBib::Organization]
    def create_org(name, addr = []) # rubocop:disable Metrics/MethodLength
      case name
      when "IEEE"
        abbr = name
        n = "Institute of Electrical and Electronics Engineers"
        url = "http://www.ieee.org"
      when "ANSI"
        abbr = name
        n = "American National Standards Institute"
        url = "https://www.ansi.org"
      else n = name
      end
      RelatonBib::Organization.new(
        name: n, abbreviation: abbr, url: url, contact: addr,
      )
    end

    #
    # Parse abstract
    #
    # @return [Array<RelatonBib::FormattedString>]
    #
    def parse_abstract
      doc.xpath("./volume/article/articleinfo/abstract").map do |a|
        RelatonBib::FormattedString.new(
          content: a.text, language: "en", script: "Latn",
        )
      end
    end

    #
    # Parse copyright
    #
    # @return [Array<RelatonBib::CopyrightAssociation>]
    #
    def parse_copyright
      doc.xpath("./publicationinfo/copyrightgroup/copyright").map do |c|
        owner = c.at("./holder").text.split("/").map do |own|
          RelatonBib::ContributionInfo.new entity: create_org(own)
        end
        RelatonBib::CopyrightAssociation.new(
          owner: owner, from: c.at("./year").text,
        )
      end
    end

    #
    # Parse status
    #
    # @return [RelatonBib::DocumentStatus]
    #
    def parse_status
      stage = doc.at("./publicationinfo/standard_status").text
      RelatonBib::DocumentStatus.new stage: stage
    end

    #
    # Parse relation
    #
    # @return [RelatonBib::DocRelationCollection]
    #
    def parse_relation # rubocop:disable Metrics/AbcSize
      rels = []
      doc.xpath("./publicationinfo/standard_relationship").each do |r|
        if (ref = fetcher.backrefs[r.text])
          rel = fetcher.create_relation(r[:type], ref)
          rels << rel if rel
        elsif !/Inactive Date/.match?(r) && docnumber
          fetcher.add_crossref(docnumber, r)
        end
      end
      RelatonBib::DocRelationCollection.new rels
    end

    #
    # Parce link
    #
    # @return [Array<RelatonBib::TypedUri>]
    #
    def parse_link
      doc.xpath("./volume/article/articleinfo/amsid").map do |id|
        l = "https://ieeexplore.ieee.org/document/#{id.text}"
        RelatonBib::TypedUri.new content: l, type: "src"
      end
    end

    #
    # Parse keyword
    #
    # @return [Array<Strign>]
    #
    def parse_keyword
      doc.xpath(
        "./volume/article/articleinfo/keywordset/keyword/keywordterm",
      ).map &:text
    end

    #
    # Parse ICS
    #
    # @return [Array<RelatonBib::ICS>]
    #
    def parse_ics
      doc.xpath("./publicationinfo/icscodes/code_term").map do |ics|
        RelatonBib::ICS.new code: ics[:codenum], text: ics.text
      end
    end
  end
end
