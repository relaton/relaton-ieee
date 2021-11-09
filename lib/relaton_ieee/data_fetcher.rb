require "zip"
require "relaton_ieee/data_parser"
require "relaton_ieee/rawbib_id_parser"

module RelatonIeee
  class DataFetcher
    RELATION_TYPES = {
      "S" => { type: "obsoletedBy" },
      "V" => { type: "updates", description: "revises" },
      "T" => { type: "updates", description: "amends" },
      "C" => { type: "updates", description: "corrects" },
      "O" => { type: "adoptedFrom" },
      "P" => { type: "complementOf", description: "supplement" },
      "N" => false, "G" => false,
      "F" => false, "I" => false,
      "E" => false, "B" => false, "W" => false
    }.freeze
    
    IDSUBSTS = {
      "2012 NESC Handbook, Seventh Edition" => "NESC HBK 2012 Ed.7",
      "2017 NESC(R) Handbook, Premier Edition" => "NESC HBK 2017 Ed.1",
      "2017 National Electrical Safety Code(R) (NESC(R)) - Redline" => "NESC C2R-2017",
      "2017 National Electrical Safety Code(R) (NESC(R))" => "NESC C2-2017",
      "52 IRE 7.S2" => "IRE 7.S2",
      "55 IRE 2.S1 (IEEE Std No 147)" => "IRE 2.S1",
      "61 IRE 15.S1 (IEEE 182)" => "IRE 15.S1",
      "61 IRE 28 S1 (IEEE 216)" => "IRE 28.S1",
      "62 IRE 12.S1 (IEEE 174)" => "IRE 12.S1",
      "62 IRE 7.S2 (IEEE 161)" => "IRE 7.S2",
      "AIEE Nos 72 and 73 - 1932" => "AIEE 72and73-1932",
      "A.I.E.E. No. 15 May-1928" => "AIEE No. 15 May-1928",
      "AIEE No 431 (105) -1958" => "AIEE No 431-1958",
      "ANSI C57.1 2.25-1990" => "ANSI C57.12.25-1990",
      "ANSI C63.022-1 996" => "ANSI C63.022-1996",
      "ANSI/IEEE Std 802.3a,b,c, and e-1988" => "ANSI/IEEE Std 802.3abce-1988",
      "Corrigendum to IEEE Std 802.3-2015 as amended by IEEE Std 802.3bw-2015, IEEE Std 802.3by-2016, IEEE Std 802.3bq-2016, IEEE Std 802.3bp-2016, IEEE Std 802.3br-2016, IEEE Std 802.3bn-2016, IEEE Std 802.3bz-2016, IEEE Std 802.3bu-2016, IEEE Std 802.3bv-2017" => "IEEE 802.3-2015/Cor 1-2017",
      "Draft National Electrical Safety Code, January 2016" => "NESC PC2, Jan 2016",
      "EEE Std 1671.1-2017 (Revision of IEEE Std 1671.1-2009)" => "IEEE Std 1671.1-2017 (Revision of IEEE Std 1671.1-2009)",
      "Electrical Safety Manual for Power and Communications Industries [Adapted from the 2017 IEEE NESC(R) Handbook Premier Edition] - Chinese Edition" => "NESC HBK 2019",
      "Guide for Implementing IEEE Std 1512" => "IEEE Guide 1512",
      "Guide for Implementing IEEE Std 1512(tm) - Using a Systems Engineering Process" => "IEEE Guide 1512tm",
      "IEC 62243 First edition 2005-07 IEEE 1232" => "IEC 62243 Ed.1 2005-07",
      "IEC 62243 Second edition 2012-06 IEEE Std 1232" => "IEC 62243 Ed.2 2012-06",
      "IEC 62271-111 First edition 2005-11; IEEE C37.60" => "IEC 62271-111 ED.1 2005-11",
      "IEC P62271-111/IEEE PC37.60_D5, February 2018" => "EC P62271-111, February 2018",
      "IEC P62271-111/IEEE PC37.60_D5, May 2015" => "IEC P62271-111, May 2015",
      "IEC/IEEE PC37.60/P62271-111_D6.1, August 2016" => "IEC/IEEE PC37.60, August 2016",
      "IEC/IEEE PC37.60/P62271-111_D9, September 2018" => "IEC/IEEE PC37.60, September 2018",
      "IEEE P1635 and ASHRAE Guideline 21/D10.1, April 2012" => "IEEE P1635, April 2012",
      "IEEE P1635 and ASHRAE Guideline 21/D8, December 2010" => "EEE P1635, December 2010",
      "IEEE P1635 and ASHRAE Guideline 21/D9, October 2011" => "IEEE P1635, October 2011",
      "IEEE P1635/ASHRAE 21/D13, December 2017" => "IEEE P1635, December 2017",
      "IEC/IEEE CDV80005-3, 2016" => "IEC/IEEE CDV 80005-3, 2016",
      "IEEE P18/D3, Oct ober 2012" => "IEEE P18/D3, October 2012",
      "IEEE P802.11aqTM/013.0 October 2017" => "IEEE P802.11aqTM/D13.0 October 2017",
      "IEEE P802.16.1/D3 Nov ember 2011" => "IEEE P802.16.1/D3 November 2011",
      "IEEE P802.16.1/D6 Apr_2012" => "IEEE P802.16.1/D6 Apr 2012",
      "IEEE P802.16.1/D6 Apr_2012_Approved Draft" => "IEEE P802.16.1/D6 Apr 2012 Approved Draft",
      "IEEE P802.1Qbu/03.0, July 2015" => "IEEE P802.1Qbu/D3.0, July 2015",
      "IEEE P802.3cv-2021/03.1, February 2021" => "IEEE P802.3cv-2021/D3.1, February 2021",
      "IEEE PC93.4/D14, Sept ember 2011" => "IEEE PC93.4/D14, September 2011",
      "IEEE SId 342-1973 (ANSI C37.0731-1973)" => "IEEE Std 342-1973 (ANSI C37.0731-1973)",
      "IEEEPC37.74/D12, May 2014" => "IEEE PC37.74/D12, May 2014",
      "IEEP62.42.1/D3, October 2014" => "IEEE P62.42.1/D3, October 2014",
      "IS0/IEC/IEEE 8802-11" => "ISO/IEC/IEEE 8802-11"
    }

    # @return [Hash] list of AMSID => PubID
    attr_reader :backrefs

    #
    # Create RelatonIeee::DataFetcher instance
    #
    # @param [String] output output dir
    # @param [Strong] format output format. Allowed values: "yaml" or "xml"
    #
    def initialize(output, format)
      @output = output
      @format = format
      @ext = format.sub(/^bib/, "")
      @crossrefs = {}
      @backrefs = {}
      @normtitles = []
    end

    #
    # Convert documents from `ieee-rawbib` dir (IEEE dataset) to BibYAML/BibXML
    #
    # @param [String] output ('data') output dir
    # @param [String] format ('yaml') output format.
    #   Allowed values: "yaml" or "xml"
    #
    def self.fetch(output: "data", format: "yaml")
      t1 = Time.now
      puts "Started at: #{t1}"
      FileUtils.mkdir_p output unless Dir.exist? output
      new(output, format).fetch
      t2 = Time.now
      puts "Stopped at: #{t2}"
      puts "Done in: #{(t2 - t1).round} sec."
    end

    #
    # Convert documents from `ieee-rawbib` dir (IEEE dataset) to BibYAML/BibXML
    #
    def fetch # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      Dir["ieee-rawbib/**/*.{xml,zip}"].reject { |f| f["Deleted_"] }.each do |f|
        xml = case File.extname(f)
              when ".zip" then read_zip f
              when ".xml" then File.read f, encoding: "UTF-8"
              end
        fetch_doc xml, f
      rescue StandardError => e
        warn "File: #{f}"
        warn e.message
        warn e.backtrace
      end
      File.write "normtitles.txt", @normtitles.join("\n")
      update_relations
    end

    #
    # Extract XML file from zip archive
    #
    # @param [String] file path to achive
    #
    # @return [String] file content
    #
    def read_zip(file)
      Zip::File.open(file) do |zf|
        entry = zf.glob("**/*.xml").first
        entry.get_input_stream.read
      end
    end

    #
    # Parse document and save it
    #
    # @param [String] xml content
    # @param [String] filename source file
    #
    def fetch_doc(xml, filename) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      doc = Nokogiri::XML(xml).at("/publication")
      nt = doc&.at("./normtitle")&.text
      ntid = @normtitles.index nt
      @normtitles << nt if nt && !ntid
      unless doc
        warn "Empty file: #{filename}"
        return
      end
      bib = DataParser.parse doc, self
      amsid = doc.at("./publicationinfo/amsid").text
      if backrefs.value?(bib.docidentifier[0].id) && /updates\.\d+/ !~ filename
        oamsid = backrefs.key bib.docidentifier[0].id
        warn "Document exists ID: \"#{bib.docidentifier[0].id}\" AMSID: "\
             "\"#{amsid}\" source: \"#{filename}\". Other AMSID: \"#{oamsid}\""
        if bib.docidentifier[0].id.include?(bib.docnumber)
          save_doc bib # rewrite file if the PubID mathces to the docnumber
          backrefs[amsid] = bib.docidentifier[0].id
        end
      else
        save_doc bib
        backrefs[amsid] = bib.docidentifier[0].id
      end
    end

    #
    # Save unresolved relation reference
    #
    # @param [String] docnumber of main document
    # @param [Nokogiri::XML::Element] amsid relation data
    #
    def add_crossref(docnumber, amsid)
      return if RELATION_TYPES[amsid[:type]] == false

      ref = { amsid: amsid.text, type: amsid[:type] }
      if @crossrefs[docnumber]
        @crossrefs[docnumber] << ref
      else @crossrefs[docnumber] = [ref]
      end
    end

    #
    # Save document to file
    #
    # @param [RelatonIeee::IeeeBibliographicItem] bib
    #
    def save_doc(bib)
      c = case @format
          when "xml" then bib.to_xml(bibdata: true)
          when "yaml" then bib.to_hash.to_yaml
          else bib.send("to_#{@format}")
          end
      File.write file_name(bib.docnumber), c, encoding: "UTF-8"
    end

    #
    # Make filename from PubID
    #
    # @param [String] docnumber
    #
    # @return [String] filename
    #
    def file_name(docnumber)
      %r{
        ^IEEE\s
        ((?<type1>Standard|Std|Draft(\sStandard|\sSupplement)?)\s)?
        ((?<series>ISO\/IEC(\/IEEE)?)\s)?
        (?<number1>[A-Z]?\d+[[:alpha:]]?)
        ([.-](?<part1>\d{1,2}(?!\d)[[:alpha:]]{0,4}))?
        (\.(?<subpart1>\d[[:alpha:]]?))?
        (?<year1>([-:]|\s-\s|,\s)\d{4})?
        (\s(IEEE\s(?<type2>Std)\s)?(?<number2>[A-Z]?\d+[[:alpha:]]?)
          ([.-](?<part2>\d{1,2}(?!\d)[[:alpha:]]{0,4}))?
          ([.](?<subpart2>\d[[:alpha:]]?))?
          (?<year2>([-:.]|_-|\s-\s|,\s)\d{4})?)?
        (\s(?<edition>Edition(\s\([^)]+\))?|First\sedition\s[\d-]+))?
        (\/(?<conform>Conformance\d{2})-(?<confyear>\d{4}))?
        (\/(?<correction>(Cor\s?|Amd\.)\d{1,2})
          (?<coryear>(:|-|:-)\d{4}))?$
      }x =~ docnumber
      name = docnumber.gsub(/\s-/, "-").gsub(/[.\s,:\/]/, "_").squeeze("_").upcase
      File.join @output, "#{name}.#{@ext}"
    end

    #
    # Update unresoverd relations
    #
    def update_relations # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      @crossrefs.each do |dnum, rfs|
        bib = nil
        rfs.each do |rf|
          if backrefs[rf[:amsid]]
            rel = create_relation(rf[:type], backrefs[rf[:amsid]])
            if rel
              bib ||= read_bib(dnum)
              bib.relation << rel
              save_doc bib
            end
          else
            warn "Unresolved relation: '#{rf[:amsid]}' type: '#{rf[:type]}' for '#{dnum}'"
          end
        end
      end
    end

    #
    # Create relation instance
    #
    # @param [String] type IEEE relation type
    # @param [String] fref reference
    #
    # @return [RelatonBib::DocumentRelation]
    #
    def create_relation(type, fref)
      return if RELATION_TYPES[type] == false

      fr = RelatonBib::FormattedRef.new(content: fref)
      bib = IeeeBibliographicItem.new formattedref: fr
      desc = RELATION_TYPES[type][:description]
      description = desc && RelatonBib::FormattedString.new(content: desc, language: "en", script: "Latn")
      RelatonBib::DocumentRelation.new(
        type: RELATION_TYPES[type][:type],
        description: description,
        bibitem: bib,
      )
    end

    #
    # Read document form BibXML/BibYAML file
    #
    # @param [String] docnumber
    #
    # @return [RelatonIeee::IeeeBibliographicItem]
    #
    def read_bib(docnumber)
      c = File.read file_name(docnumber), encoding: "UTF-8"
      case @format
      when "xml" then XMLParser.from_xml c
      when "bibxml" then BibXMLParser.parse c
      else IeeeBibliographicItem.from_hash YAML.safe_load(c)
      end
    end
  end
end
