require "ieee-idams"

module RelatonIeee
  class IdamsParser
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
      @docnumber ||= pubid&.to_id
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
      @doc.btitle.map { |args| RelatonBib::TypedTitleString.new(**args) }
    end

    #
    # Parse date
    #
    # @return [Array<RelatonBib::BibliographicDate>]
    #
    def parse_date
      @doc.bdate.map { |args| RelatonBib::BibliographicDate.new(**args) }
    end

    #
    # Parse identifiers
    #
    # @return [Array<RelatonBib::DocumentIdentifier>]
    #
    def parse_docid # rubocop:disable Metrics/MethodLength
      ids = @doc.isbn_doi

      ids.unshift(id: pubid.to_s(trademark: true), scope: "trademark", type: "IEEE", primary: true)
      ids.unshift(id: pubid.to_s, type: "IEEE", primary: true)

      ids.map { |dcid| RelatonBib::DocumentIdentifier.new(**dcid) }
    end

    #
    # Parse contributors
    #
    # @return [Array<RelatonBib::ContributionInfo>]
    #
    def parse_contributor
      name, addr = @doc.contrib_name_addr { |args| RelatonBib::Address.new(**args) }

      entity = create_org name, addr
      [RelatonBib::ContributionInfo.new(entity: entity, role: [type: "publisher"])]
    end

    #
    # Parse abstract
    #
    # @return [Array<RelatonBib::FormattedString>]
    #
    def parse_abstract
      @doc.volume.article.articleinfo.abstract.each_with_object([]) do |abs, acc|
        next unless abs.abstract_type == "Standard"

        acc << RelatonBib::FormattedString.new(content: abs.value, language: "en", script: "Latn")
      end
    end

    #
    # Parse copyright
    #
    # @return [Array<RelatonBib::CopyrightAssociation>]
    #
    def parse_copyright
      @doc.copyright.map do |owner, year|
        contrib = owner.map { |own| RelatonBib::ContributionInfo.new entity: create_org(own) }
        RelatonBib::CopyrightAssociation.new(owner: contrib, from: year)
      end
    end

    #
    # Parse status
    #
    # @return [RelatonIee::DocumentStatus, nil]
    #
    def parse_docstatus
      @doc.docstatus { |args| DocumentStatus.new(**args) }
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
      @doc.link { |url| RelatonBib::TypedUri.new(content: url, type: "src") }
    end

    #
    # Parse keyword
    #
    # @return [Array<Strign>]
    #
    def parse_keyword
      @doc.keyword
    end

    #
    # Parse ICS
    #
    # @return [Array<RelatonBib::ICS>]
    #
    def parse_ics
      @doc.ics { |ics| RelatonBib::ICS.new(**ics) }
    end

    #
    # Parse editorialgroup
    #
    # @return [RelatonIeee::EditorialGroup, nil] editorialgroup or nil
    #
    def parse_editorialgroup
      @doc.editorialgroup { |committee| EditorialGroup.new committee: committee }
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
      @doc.standard_modifier
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
      DocumentType.new type: @doc.doctype
    end

    private

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
      RelatonBib::Organization.new(name: n, abbreviation: abbr, url: url, contact: addr)
    end
  end
end
