module RelatonIeee
  class DataParser
    DATETYPES = { "OriginalPub" => "created", "ePub" => "published",
                  "LastInspecUpd" => "updated" }.freeze
    ATTRS = %i[
      docnumber title date docid contributor abstract copyright docstatus
      relation link keyword ics editorialgroup standard_status standard_modified
      pubstatus holdstatus doctype
    ].freeze

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
    def parse
      args = { type: "standard", language: ["en"], script: ["Latn"] }
      ATTRS.each { |attr| args[attr] = send("parse_#{attr}") }
      IeeeBibliographicItem.new(**args)
    end

    #
    # Parse title
    #
    # @return [Array<RelatonBib::TypedTitleString>]
    #
    def parse_title
      t = []
      content = CGI.unescapeHTML doc.at("./volume/article/title").text
      if content =~ /\A(.+)\s[-\u2014]\sredline\z/i
        t << RelatonBib::TypedTitleString.new(content: $1, type: "title-main")
      end
      t << RelatonBib::TypedTitleString.new(content: content, type: "main")
    end

    #
    # Parse date
    #
    # @return [Array<RelatonBib::BibliographicDate>]
    #
    def parse_date # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
      dates = doc.xpath("./volume/article/articleinfo/date").map do |d|
        da = [d.at("./year").text]
        m = d.at("./month")&.text
        if m
          /^(?:(?<day>\d{1,2})\s)?(?<mon>\w+)/ =~ m
          month = Date::ABBR_MONTHNAMES.index(mon) || Date::MONTHNAMES.index(mon) || m
          da << month.to_s.rjust(2, "0")
        end
        day = d.at("./day")&.text || day
        da << day.rjust(2, "0") if day
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
    def parse_docid # rubocop:disable Metrics/MethodLength
      ids = [
        { id: pubid.to_s, type: "IEEE", primary: true },
        { id: pubid.to_s(trademark: true), scope: "trademark", type: "IEEE", primary: true },
      ]
      isbn = doc.at("./publicationinfo/isbn")
      ids << { id: isbn.text, type: "ISBN" } if isbn
      doi = doc.at("./volume/article/articleinfo/articledoi")
      ids << { id: doi.text, type: "DOI" } if doi
      ids.map do |dcid|
        RelatonBib::DocumentIdentifier.new(**dcid)
      end
    end

    #
    # Create PubID
    #
    # @return [RelatonIeee::RawbibIdParser] PubID
    #
    def pubid
      @pubid ||= begin
        normtitle = doc.at("./normtitle").text
        stdnumber = doc.at("./publicationinfo/stdnumber")&.text
        RawbibIdParser.parse(normtitle, stdnumber)
      end
    end

    def parse_docnumber
      docnumber
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
        addr = contrib.xpath("./address").each_with_object([]) do |adr, ob|
          city, country, state = parse_country_city adr
          next unless city && country

          ob << RelatonBib::Address.new(street: [], city: city, state: state, country: country)
        end
        e = create_org n, addr
        RelatonBib::ContributionInfo.new entity: e, role: [type: "publisher"]
      end
    end

    def parse_country_city(address)
      city = address.at("./city")
      return unless city

      city, state = city.text.split(", ")
      country = address.at("./country")&.text || "USA"
      [city, country, state]
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
      doc.xpath("./volume/article/articleinfo/abstract")[0...1].map do |a|
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
    # @return [RelatonIee::DocumentStatus, nil]
    #
    def parse_docstatus
      st = parse_standard_modified
      return unless %w[Draft Approved Superseded Withdrawn].include?(st)

      DocumentStatus.new stage: st.downcase
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
        elsif !"Inactive Date".include?(r) && docnumber
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

    #
    # Parse editorialgroup
    #
    # @return [RelatonIeee::EditorialGroup, nil] editorialgroup or nil
    #
    def parse_editorialgroup
      committee = doc.xpath(
        "./publicationinfo/pubsponsoringcommitteeset/pubsponsoringcommittee",
      ).map &:text
      EditorialGroup.new committee: committee if committee.any?
    end

    #
    # Parse standard status
    #
    # @return [String, nil] standard status or nil
    #
    def parse_standard_status
      doc.at("./publicationinfo/standard_status")&.text
    end

    #
    # Parse standard modifier
    #
    # @return [String, nil] standard modifier or nil
    #
    def parse_standard_modified
      doc.at("./publicationinfo/standardmodifierset/standard_modifier")&.text
    end

    #
    # Parse pubstatus
    #
    # @return [String, nil] pubstatus or nil
    #
    def parse_pubstatus
      doc.at("./publicationinfo/pubstatus")&.text
    end

    #
    # Pasrse holdstatus
    #
    # @return [String, nil] holdstatus or nil
    #
    def parse_holdstatus
      doc.at("./publicationinfo/holdstatus")&.text
    end

    #
    # Parse doctype
    #
    # @return [String] doctype
    #
    def parse_doctype
      type = parse_standard_modified == "Redline" ? "redline" : "standard"
      DocumentType.new type: type
    end
  end
end
