require "ieee-idams"

module RelatonIeee
  class IdamsParser
    DATETYPES = { "OriginalPub" => "created", "ePub" => "published",
                  "LastInspecUpd" => "updated" }.freeze
    ATTRS = %i[
      docnumber title date docid contributor abstract copyright docstatus
      relation link keyword ics editorialgroup standard_status standard_modified
      pubstatus holdstatus doctype
    ].freeze

    def initialize(doc, fetcher)
      @doc = doc
      @fetcher = fetcher
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
    # Create PubID
    #
    # @return [RelatonIeee::RawbibIdParser] PubID
    #
    def pubid
      @pubid ||= begin
        normtitle = @doc.normtitle
        stdnumber = @doc.publicationinfo.stdnumber
        RawbibIdParser.parse(normtitle, stdnumber)
      end
    end

    #
    # Parse title
    #
    # @return [Array<RelatonBib::TypedTitleString>]
    #
    def parse_title
      t = []
      content = CGI.unescapeHTML @doc.volume.article.first.title
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
    def parse_date
      dates = @doc.volume.article.first.articleinfo.date.map do |date|
        date_array = [date.year]
        if date.month
          /^(?:(?<day>\d{1,2})\s)?(?<mon>\w+)/ =~ date.month
          month = Date::ABBR_MONTHNAMES.index(mon) || Date::MONTHNAMES.index(mon) || date.month
          date_array << month.to_s.rjust(2, "0")
        end
        day = date.day || day
        date_array << day.rjust(2, "0") if day
        on = date_array.compact.join "-"
        RelatonBib::BibliographicDate.new type: DATETYPES[date.datetype], on: on
      end
      if @doc.publicationinfo.pubapprovaldate
        issued = parse_date_string @doc.publicationinfo.pubapprovaldate
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
      isbn = @doc.publicationinfo.isbn
      ids << { id: isbn.first.content, type: "ISBN" } if isbn.any?
      doi = @doc.volume.article[0].articleinfo.articledoi
      ids << { id: doi, type: "DOI" } if doi
      ids.map do |dcid|
        RelatonBib::DocumentIdentifier.new(**dcid)
      end
    end

    #
    # Parse contributors
    #
    # @return [Array<RelatonBib::ContributionInfo>]
    #
    def parse_contributor
      contrib = @doc.publicationinfo.publisher
      name = contrib.publishername
      addr = create_addres contrib.address

      entity = create_org name, addr
      [RelatonBib::ContributionInfo.new(entity: entity, role: [type: "publisher"])]
    end

    def create_addres(address)
      return [] unless address&.city

      city, state = address.city.split(", ")
      country = address.country || "USA"
      return [] unless city && country

      [RelatonBib::Address.new(street: [], city: city, state: state, country: country)]
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
      @doc.volume.article[0].articleinfo.abstract.map do |abs|
        RelatonBib::FormattedString.new(content: abs.value, language: "en", script: "Latn")
      end
    end

    #
    # Parse copyright
    #
    # @return [Array<RelatonBib::CopyrightAssociation>]
    #
    def parse_copyright
      @doc.publicationinfo.copyrightgroup.copyright.map do |c|
        owner = c.holder.split("/").map do |own|
          RelatonBib::ContributionInfo.new entity: create_org(own)
        end
        RelatonBib::CopyrightAssociation.new(owner: owner, from: c.year.to_s)
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
      @doc.publicationinfo.standard_relationship&.each do |relation|
        if (ref = @fetcher.backrefs[relation.date_string])
          rel = @fetcher.create_relation(relation.type, ref)
          rels << rel if rel
        elsif !relation.date_string.include?("Inactive Date") && docnumber
          @fetcher.add_crossref(docnumber, relation)
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
      id = @doc.volume.article[0].articleinfo.amsid
      url = "https://ieeexplore.ieee.org/document/#{id}"
      [RelatonBib::TypedUri.new(content: url, type: "src")]
    end

    #
    # Parse keyword
    #
    # @return [Array<Strign>]
    #
    def parse_keyword
      @doc.volume.article[0].articleinfo.keywordset[0]&.keyword&.map &:keywordterm
    end

    #
    # Parse ICS
    #
    # @return [Array<RelatonBib::ICS>]
    #
    def parse_ics
      return [] unless @doc.publicationinfo.ics_codes

      @doc.publicationinfo.ics_codes.code_term.map do |ics|
        RelatonBib::ICS.new code: ics.codenum, text: ics.name
      end
    end

    #
    # Parse editorialgroup
    #
    # @return [RelatonIeee::EditorialGroup, nil] editorialgroup or nil
    #
    def parse_editorialgroup
      committee = @doc.publicationinfo.pubsponsoringcommitteeset&.pubsponsoringcommittee
      EditorialGroup.new committee: committee if committee&.any?
    end

    #
    # Parse standard status
    #
    # @return [String, nil] standard status or nil
    #
    def parse_standard_status
      @doc.publicationinfo.standard_status
    end

    #
    # Parse standard modifier
    #
    # @return [String, nil] standard modifier or nil
    #
    def parse_standard_modified
      @doc.publicationinfo.standard_modifier_set&.standard_modifier
    end

    #
    # Parse pubstatus
    #
    # @return [String, nil] pubstatus or nil
    #
    def parse_pubstatus
      @doc.publicationinfo.pubstatus
    end

    #
    # Pasrse holdstatus
    #
    # @return [String, nil] holdstatus or nil
    #
    def parse_holdstatus
      @doc.publicationinfo.holdstatus
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
