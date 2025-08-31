require "relaton_ieee/pub_id"

module RelatonIeee
  module RawbibIdParser
    STAGE = '(?<stage>DIS\d?|PSI|FCD|FDIS|CD\d?|Pub2|CDV|TS|SI)'.freeze
    APPROVAL = '(?:\s(?<approval>Unapproved|Approved))'.freeze
    APPROV = '(?:\s(?:Unapproved|Approved))?'.freeze
    STD = "(?<std>\s(?i)Std.?(?-i))?".freeze

    #
    # Parse normtitle
    #
    # @param [String] normtitle document element "normtitle"
    # @param [String] stdnumber document element "stdnumber"
    #
    # @return [RelatonIeee::PubId, nil]
    #
    def parse(normtitle, stdnumber) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      case normtitle.sub(/^ISO\s(?=\/)/, "ISO").sub(/^ANSI\/\s(?=IEEE)/, "ANSI/")
      # when "2012 NESC Handbook, Seventh Edition" then "NESC HBK ED7.2012"
      # when "2017 NESC(R) Handbook, Premier Edition" then "NESC HBK ED1.2017"
      # when "2017 National Electrical Safety Code(R) (NESC(R)) - Redline" then "NESC C2R.2017"
      # when "2017 National Electrical Safety Code(R) (NESC(R))" then "NESC C2.2017"
      # when /^(\d+HistoricalData)-(\d{4})/ then "IEEE #{$1}.#{$2}"
      # when /^(\d+)\.(\w+)\sBattery\sLife\sImprovement/ then "IEEE #{$1}-#{$2}"
      # when /^(\d+)\.(\w+)-(\d{4})\s\(Amendment/ then "IEEE #{$1}-#{$2}.#{$3}"
      when "A.I.E.E. No. 15 May-1928" then PubId.new(publisher: "AIEE", number: "15", year: "1928", month: "05")
      # when "AIEE Nos 72 and 73 - 1932" then "AIEE 72_73.1932"
      when "IEEE Std P1073.1.3.4/D3.0" then PubId.new(publisher: "IEEE", std: true, number: "P11073", part: "00101") # "IEEE Std P11073-00101"
      # when "P1073.1.3.4/D3.0" then PubId.new(publisher: "IEEE", number: "P1073", part: "1-3-4", draft: "3.0") # "IEEE P1073-1-3-4/D3.0"
      when "IEEE P1073.2.1.1/D08" then PubId.new(publisher: "ISO/IEEE", number: "P1073", part: "2-1-1", draft: "08") # "ISO/IEEE P1073-2-1-1/D08"
      when "IEEE P802.1Qbu/03.0, July 2015" # "IEEE P802.1Qbu/D3.0.2015"
        PubId.new(publisher: "IEEE", number: "P802", part: "1Qbu", draft: "3.0", year: "2015")
      when "IEEE P11073-10422/04, November 2015" # "IEEE P11073-10422/D04.2015"
        PubId.new(publisher: "IEEE", number: "P11073", part: "10422", draft: "04", year: "2015")
      when "IEEE P802.11aqTM/013.0 October 2017" # "IEEE P802-11aqTM/D13.0.2017"
        PubId.new(publisher: "IEEE", number: "P802", part: "11aqTM", draft: "13.0", year: "2017")
      when "IEEE P844.3/C22.2 293.3/D0, August 2018" # "IEEE P844-3/C22.2-293.3/D0.2018"
        PubId.new([{ publisher: "IEEE", number: "P844", part: "3" },
                   { number: "C22.2", part: "293.3", dtaft: "0", year: "2018" }])
      when "IEEE P844.3/C22.2 293.3/D1, November 2018" # "IEEE P844.3/C22.2 293.3/D1.2018"
        PubId.new([{ publisher: "IEEE", number: "P844", part: "3" },
                   { number: "C22.2", part: "293.3", draft: "1", year: "2018" }])
      when "AIEE No 431 (105) -1958" then PubId.new(publisher: "AIEE", number: "431", year: "1958") # "AIEE 431.1958"
      when "IEEE 1076-CONC-I99O" then PubId.new(publisher: "IEEE", number: "1076", year: "199O") # "IEEE 1076.199O"
      when "IEEE Std 960-1993, IEEE Std 1177-1993" # "IEEE 960/1177.1993"
        PubId.new([{ publisher: "IEEE", std: true, number: "960" }, { number: "1177", year: "1993" }])
      when "IEEE P802.11ajD8.0, August 2017" # "IEEE P802-11aj/D8.0.2017"
        PubId.new(publisher: "IEEE", number: "P802", part: "11aj", draft: "8.0", year: "2017")
      when "IEEE P802.11ajD9.0, November 2017" # "IEEE P802-11aj/D9.0.2017"
        PubId.new(publisher: "IEEE", number: "P802", part: "11aj", draft: "9.0", year: "2017")
      when "ISO/IEC/IEEE P29119-4-DISMay2013" # "ISO/IEC/IEEE DIS P29119-4.2013"
        PubId.new(publisher: "ISO/IEC/IEEE", stage: "DIS", number: "P29119", part: "4", year: "2013")
      when "IEEE-P15026-3-DIS-January 2015" # "IEEE DIS P15026-3.2015"
        PubId.new(publisher: "IEEE", stage: "DIS", number: "P15026", year: "2015")
      when "ANSI/IEEE PC63.7/D rev17, December 2014" # "ANSI/IEEE PC63-7/D/REV-17.2014"
        PubId.new(publisher: "ANSI/IEEE", number: "PC63", part: "7", draft: "", rev: "17", year: "2014")
      when "IEC/IEEE P62271-37-013:2015 D13.4" # "IEC/IEEE P62271-37-013/D13.4.2015"
        PubId.new(publisher: "IEC/IEEE", number: "P62271", part: "37-013", draft: "13.4", year: "2015")
      when "PC37.30.2/D043 Rev 18, May 2015" # "IEEE PC37-30-2/D043/REV-18.2015"
        PubId.new(publisher: "IEEE", number: "PC37", part: "30-2", draft: "043", rev: "18", year: "2015")
      when "IEC/IEEE FDIS 62582-5 IEC/IEEE 2015" # "IEC/IEEE FDIS 62582-5.2015"
        PubId.new(publisher: "IEC/IEEE", stage: "FDIS", number: "62582", part: "5", year: "2015")
      when "ISO/IEC/IEEE P15289:2016, 3rd Ed FDIS/D2" # "ISO/IEC/IEEE FDIS P15289/E3/D2.2016"
        PubId.new(publisher: "ISO/IEC/IEEE", stage: "FDIS", number: "P15289", part: "", edition: "3", draft: "2", year: "2016")
      when "IEEE P802.15.4REVi/D09, April 2011 (Revision of IEEE Std 802.15.4-2006)"
        PubId.new(publisher: "IEEE", number: "P802", part: "15.4", rev: "i", draft: "09", year: "2013", month: "04", approval: "Approved")
      when "Draft IEEE P802.15.4REVi/D09, April 2011 (Revision of IEEE Std 802.15.4-2006)"
        PubId.new(publisher: "IEEE", number: "P802", part: "15.4", rev: "i", draft: "09", year: "2011", month: "04")
      when "ISO/IEC/IEEE DIS P42020:201x(E), June 2017"
        PubId.new(publisher: "ISO/IEC/IEEE", stage: "DIS", number: "P42020", year: "2017", month: "06")
      when "IEEE/IEC P62582 CD2 proposal, May 2017"
        PubId.new(publisher: "IEEE/IEC", number: "P62582", stage: "CD2", year: "2017", month: "05")
      when "ISO/IEC/IEEE P16326:201x WD.4a, July 2017"
        PubId.new(publisher: "ISO/IEC/IEEE", number: "P16326", draft: "4a", year: "2017", month: "07")
      when "ISO/IEC/IEEE CD.1 P21839, October 2017"
        PubId.new(publisher: "ISO/IEC/IEEE", stage: "CD1", number: "P21839", year: "2017", month: "10")
      when "IEEE P3001.2/D5, August 2017"
        PubId.new(publisher: "IEEE", number: "P3001", part: "2", draft: "5", year: "2017", month: "01")
      when "P3001.2/D5, August 2017"
        PubId.new(publisher: "IEEE", number: "P3001", part: "2", draft: "5", year: "2017", month: "12")
      when "ISO/IEC/IEEE P16326:201x WD5, December 2017"
        PubId.new(publisher: "ISO/IEC/IEEE", number: "P16326", draft: "5", year: "2017", month: "12")
      when "ISO/IEC/IEEE DIS P16326/201x, December 2018"
        PubId.new(publisher: "ISO/IEC/IEEE", stage: "DIS", number: "P16326", year: "2018", month: "12")
      when "ISO/IEC/IEEE/P21839, 2019(E)"
        PubId.new(publisher: "ISO/IEC/IEEE", number: "P21839", year: "2019")
      when "ISO/IEC/IEEE P42020/V1.9, August 2018"
        PubId.new(publisher: "ISO/IEC/IEEE", number: "P42020", year: "2018", month: "08")
      when "ISO/IEC/IEEE CD2 P12207-2: 201x(E), February 2019"
        PubId.new(publisher: "ISO/IEC/IEEE", stage: "CD2", number: "P12207", part: "2", year: "2019", month: "02")
      when "ISO/IEC/IEEE P42010.WD4:2019(E)"
        PubId.new(publisher: "ISO/IEC/IEEE", number: "P42010", draft: "4", year: "2019")
      when "IEC/IEEE P63195_CDV/V3, February 2020"
        PubId.new(publisher: "IEC/IEEE", number: "P63195", stage: "CDV", year: "2020", month: "02")
      when "IEEE/ISO/IEC P42010.CD1-V1.0, April 2020"
        PubId.new(publisher: "IEEE/ISO/IEC", number: "P42010", stage: "CD1", year: "2020", month: "04")
      when "ISO/IEC/IEEE/P16085_DIS, March 2020"
        PubId.new(publisher: "ISO/IEC/IEEE", stage: "DIS", number: "P16085", year: "2020", month: "03")
      when "ANSI/IEEE Std: Outdoor Apparatus Bushings"
        PubId.new(publisher: "ANSI/IEEE", std: true, number: "21", year: "1976", month: "11")
      when "Unapproved Draft Std ISO/IEC FDIS 15288:2007(E) IEEE P15288/D3,"
        PubId.new(publisher: "ISO/IEC/IEEE", stage: "FDIS", std: true, number: "P15288", draft: "3", year: "2007")
      when "Draft National Electrical Safety Code, January 2016"
        PubId.new(publisher: "IEEE", number: "PC2", year: "2016", month: "01")
      when "ANSI/IEEE-ANS-7-4.3.2-1982" then PubId.new(publisher: "ANSI/IEEE/ANS", number: "7", part: "4-3-2", year: "1982")
      when "IEEE Unapproved Draft Std P802.1AB/REVD2.2, Dec 2007" # "IEEE P802.1AB/REV/D2.2.2007"
        PubId.new(publisher: "IEEE", std: true, number: "P802", part: "1AB", rev: "", draft: "2.2", year: "2007", month: "12")
      when "International Standard ISO/IEC 8802-9: 1996(E) ANSI/IEEE Std 802.9, 1996 Edition"
        PubId.new(publisher: "ISO/IEC/IEEE", std: true, number: "802", part: "9", year: "1996")
      when "ISO/IEC13210: 1994 (E) ANSI/IEEE Std 1003.3-1991"
        PubId.new(publisher: "ISO/IEC/IEEE", number: "13210", year: "1994")
      when "J-STD-016-1995" then PubId.new(publisher: "IEEE", number: "016", year: "1995")
      when "Std 802.1ak-2007 (Amendment to IEEE Std 802.1QTM-2005)"
        PubId.new(publisher: "IEEE", std: true, number: "802", part: "1ak", year: "2007")
      when "IS0/IEC/IEEE 8802-11:2012/Amd.5:2015(E) (Adoption of IEEE Std 802.11af-2014)"
        PubId.new(publisher: "ISO/IEC/IEEE", number: "802", part: "11", year: "2012", amd: "5", year_amendment: "2015")
      when "National Electrical Safety Code, C2-2012 - Redline"
        PubId.new(publisher: "IEEE", number: "C2", year: "2012", redline: "true")
      when "National Electrical Safety Code, C2-2012" then PubId.new(publisher: "IEEE", number: "C2", year: "2012")
      when "2012 NESC Handbook, Seventh Edition" then PubId.new(publisher: "NESC", number: "HBK", year: "2012")
      when /^Amendment to IEEE Std 802\.11-2007 as amended by IEEE Std 802\.11k-2008/
        PubId.new(publisher: "IEEE", std: true, number: "802", part: "11u", year: "2007")
      when "Std 11073-10417-2009" then PubId.new(publisher: "IEEE", std: true, number: "11073", part: "10417", year: "2009")
      when "Nuclear EQ Sourcebook and Supplement" then PubId.new publisher: "IEEE", number: "7438946"

      # drop all with <standard_id>0</standard_id>
      # when "IEEE Std P1671/D5, June 2006", "IEEE Std PC37.100.1/D8, Dec 2006",
      #      "IEEE Unapproved Draft Std P1578/D17, Mar 2007", "IEEE Approved Draft Std P1115a/D4, Feb 2007",
      #      "IEEE Std P802.16g/D6, Nov 06", "IEEE Unapproved Draft Std P1588_D2.2, Jan 2008",
      #      "IEEE Unapproved Std P90003/D1, Feb 2007.pdf", "IEEE Unapproved Draft Std PC37.06/D10 Dec 2008",
      #      "IEEE P1451.2/D20, February 2011", "IEEE Std P1641.1/D3, July 2006",
      #      "IEEE P802.1AR-Rev/D2.2, September 2017 (Draft Revision of IEEE Std 802.1AR\u20132009)",
      #      "IEEE Std 108-1955; AIEE No.450-April 1955", "IEEE Std 85-1973 (Revision of IEEE Std 85-1965)",
      #      "IEEE Std 1003.1/2003.l/lNT, March 1994 Edition" then nil

      # publisher1, number1, part1, publisher2, number2, part2, draft, year
      when /^([A-Z\/]+)\s(\w+)[-.](\d+)\/(\w+)\s(\w+)[-.](\d+)_D([\d.]+),\s\w+\s(\d{4})/
        PubId.new([{ publisher: $1, number: $2, part: $3 },
                   { publisher: $4, number: $5, part: $6, draft: dn($7), year: $8 }])

      # publisher1, number1, part1, number2, part2, draft, year, month
      when /^([A-Z\/]+)\s(\w+)[.-]([\w.-]+)\/(\w+)[.-]([[:alnum:].-]+)[\/_]D([\w.]+),\s(\w+)\s(\d{4})/
        PubId.new([{ publisher: $1, number: $2, part: sp($3) }, { number: $4, part: sp($5), draft: dn($6), year: $8, month: mn($7) }])

      # publisher, approval, number, part, corrigendum, draft, year
      when /^(?<publisher>[A-Z\/]+)#{APPROVAL}(?:\sDraft)?\sStd\s(?<number>\w+)\.(?<part>\d+)-\d{4}[^\/]*\/Cor\s?(?<corr>\d)\/(?<draft>D[\d\.]+),\s(?:\w+\s)?(?<year>\d{4})/o
        create_pubid(Regexp.last_match)

      # publisher, number, part, corrigendum, draft, year, month
      when /^(?<publisher>[A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(?<number>\w+)\.(?<part>\w+)-\d{4}\/Cor\s?(?<corr>\d(?:-\d+x)?)[\/_]D(?<draft>[\d\.]+),\s?(?<month>\w+)\s(?<year>\d{4})/o
        create_pubid(Regexp.last_match)

      # publidsher1, number1, year1 publisher2, number2, draft, year2
      when /^([A-Z\/]+)\s(\w+)-(\d{4})\/([A-Z]+)\s([[:alnum:]]+)_D([\w.]+),\s(\d{4})/
        PubId.new([{ publisher: $1, number: $2, year: $3 }, { publisher: $4, number: $5, draft: dn($6), year: $7 }])

      when /^(?<publisher>[A-Z\/]+)\s#{STAGE}\s(?<number>\w+)[.-](?<part>[[:alnum:].-]+)[\s\/_]ED(?<edition>[\w.]+),\s(?<month>\w+)\s(?<year>\d{4})/o
        create_pubid(Regexp.last_match)

      # publidsher1, number1, publisher2, number2, draft, year
      when /^(?<publisher1>[A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(?<number1>\w+)\/(?<publisher2>[A-Z]+)\s(?<number2>[[:alnum:]]+)_D(?<draft>[\d\.]+),\s\w+\s(?<year>\d{4})/o,
           /^(?<publisher1>[A-Z\/]+)\s(?<number1>\w+)\sand\s(?<publisher2>[A-Z]+)(?:\sGuideline)?\s(?<number2>[[:alnum:]]+)\/D(?<draft>[\d\.]+),\s\w+\s(?<year>\d{4})/o
        nc = Regexp.last_match.named_captures
        PubId.new([{ publisher: nc["publisher1"], std: !!nc["std"], number: nc["number1"] },
                   { publisher: nc["publisher2"], number: nc["number2"], draft: dn(nc["draft"]), year: nc["year"] }])

      # publidsher1, number1, part, publisher2, number2, year
      when /^([A-Z\/]+)\s(\w+)\.(\d+)_(\w+)\s(\w+),\s(\d{4})/ # "#{$1} #{$2}-#{$3}/#{$4} #{$5}.#{$6}"
        PubId.new([{ publisher: $1, number: $2, part: $3 }, { publisher: $4, number: $5, year: $6 }])

      # publisher, number1, part1, number2, part2, draft
      when /^([A-Z\/]+)\s(\w+)[.-](\d+)\/(\w+)\.(\d+)[\/_]D([\d.]+)/ # "#{$1} #{$2}-#{$3}/#{$4}-#{$5}/D#{$6}"
        PubId.new([{ publisher: $1, number: $2, part: $3 }, { number: $4, part: $5, draft: dn($6) }])

      # publidsher, number1, part1, number2, part2, year
      when /^([A-Z\/]+)\sStd\s(\w+)\.(\w+)\/(\w+)\.(\w+)\/INT\s\w+\s(\d{4})/
        PubId.new([{ publisher: $1, number: $2, part: $3 }, { number: $4, part: $5, year: $6 }])

      # publisher, number, part, corrigendum, draft, year
      when /^(?<publisher>[A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(?<number>\w+)[.-](?<part>[\d-]+)\/Cor\s?(?<corr>\d)[\/_]D(?<draft>[\d\.]+),\s(?:\w+\s)?(?<year>\d{4})/o,
           /^(?<publisher>[A-Z\/]+)\s(?<number>\w+)[.-](?<part>\d+)-\d{4}\/Cor\s?(?<corr>\d)(?:-|,\s|\/)D(?<draft>[\d.]+),?\s\w+\s(?<year>\d{4})/,
           /^(?<publisher>[A-Z\/]+)\s(?<number>\w+)\.(?<part>[[:alnum:].]+)[-_]Cor[\s-]?(?<corr>\d)\/D(?<draft>[\d.]+),?\s\w+\s(?<year>\d{4})/
        create_pubid(Regexp.last_match)
      when /^([A-Z\/]+)\s(\w+)\.(\d+)-\d{4}\/Cor(\d)-(\d{4})\/D([\d.]+)/ # "#{$1} #{$2}-#{$3}/Cor#{$4}/D#{$6}.#{$5}"
        PubId.new(publisher: $1, number: $2, part: $3, corr: $4, draft: dn($6), year: $5)

      # publisher, status, number, part, draft, year, month
      when /^(?<publisher>[A-Z\/]+)(?<status>\sActive)#{APPROV}(?:\sDraft)?#{STD}\s(?<number>\w+)[.-](?<part>[[:alnum:]\.]+)\s?[\/_]D(?<draft>[\w\.]+),?\s(?<month>\w+)(?:\s\d{1,2},)?\s?(?<year>\d{2,4})/o
        create_pubid(Regexp.last_match)

      # publisher, approval, number, part, draft, year, month
      when /^(?<publisher>[A-Z\/]+)(?:\sActive)?#{APPROVAL}(?:\sDraft)?#{STD}\s(?<number>\w+)[.-](?<part>[[:alnum:]\.]+)\s?[\/_]D(?<draft>[\w\.-]+),?\s(?<month>\w+)(?:\s\d{1,2},)?\s?(?<year>\d{2,4})/o,
        /^(?<publisher>[A-Z\/]+)\s(?<number>\w+)\.(?<part>[\w.]+)\/D(?<draft>[\w.]+),?\s(?<month>\w+)[\s_](?<year>\d{4})(?:\s-\s\(|\s\(|_)#{APPROVAL}/
        create_pubid(Regexp.last_match)

      # publisher, approval, number, draft, year, month
      when /^(?<publisher>[A-Z\/]+)\s(?<number>\w+)\/D(?<draft>[\w.]+),\s(?<month>\w+)\s(?<year>\d{4})\s-\s\(?#{APPROVAL}/
        create_pubid(Regexp.last_match)

      # publisher, approval, number, part, draft, year
      when /^(?<publisher>[A-Z\/]+)#{APPROVAL}(?:\sDraft)?#{STD}\s(?<number>\w+)[.-](?<part>[\w.]+)\s?[\/_\s]D(?<draft>[\w\.]+),?\s\w+\s?(?<year>\d{4})/o,
        /^(?<publisher>[A-Z\/]+)\s(?<number>\w+)\.(?<part>[\w.]+)\/D(?<draft>[\d.]+),?\s\w+[\s_](?<year>\d{4})(?:\s-\s\(|_|\s\()?#{APPROVAL}/o
        create_pubid(Regexp.last_match)

      # publisher, stage, number, part, edition, year, month
      when /^(?<publisher>[A-Z\/]+)\s(?<number>\w+)[.-](?<part>[[:alnum:].-]+)[\/_]#{STAGE}\s(?<edition>\w+)\sedition,\s(?<month>\w+)\s(?<year>\d{4})/o
        create_pubid(Regexp.last_match)

      # number, part, corrigendum, draft, year
      when /^(?<number>\w+)\.(?<part>[\w.]+)-\d{4}[_\/]Cor\s?(?<corr>\d)\/D(?<draft>[\w.]+),?\s\w+\s(?:\d{2},\s)?(?<year>\d{4})/
        create_pubid(Regexp.last_match)

      # publisher, approval, number, part, draft
      when /^(?<publisher>[A-Z\/]+)\s(?<number>\w+)\.(?<part>\d+)\/D(?<draft>[\d.]+)\s\([^)]+\)\s-#{APPROVAL}/o
        create_pubid(Regexp.last_match)

      # publisher, number, part1, rev, draft, part2
      when /^(?<publisher>[A-Z\/]+)#{STD}\s(?<number>\w+)\.(?<part>[\d.]+)REV(?<rev>[a-z]+)_D(?<draft>[\w.]+)\sPart\s(?<part2>\d)/o
        create_pubid(Regexp.last_match)

      # publisher, number, part, draft, year, month
      when /^(?<publisher>[A-Z\/]+)#{STD}\s(?<number>\w+)[.-](?<part>[[:alnum:].]+)[\/\s_]D(?<draft>[\d.]+)(?:,?\s|_)(?<month>[[:alpha:]]+)[\s_]?(?<year>\d{4})/o
        create_pubid(Regexp.last_match)

      # publisher, stage, number, part, draft, year
      when /^(?<publisher>[\w\/]+)\s(?<stage>#{STAGE})\s(?<number>\w+)-(?<part>[[:alnum:]]+)[\/_\s]D(?<draft>[\d.]+),\s\w+\s(?<year>\d{4})/o
        create_pubid(Regexp.last_match)

      # publisher, number, part, rev, draft, year, month
      when /^(?<publisher>[A-Z\/]+)\s(?<number>\w+)\.(?<part>[\w.]+)-Rev\/D(?<draft>[\w.]+),\s(?<month>\w+)\s(?<year>\d{4})/
        create_pubid(Regexp.last_match)

      # publisher, number, part, rev, draft, year
      when /^(?<publisher>[A-Z\/]+)\s(?<number>\w+)\.(?<part>[\d.]+)Rev(?<rev>\w+)-D(?<draft>[\w.]+),\s\w+\s(?<year>\d{4})/
        create_pubid(Regexp.last_match)

      # publisher, stage, number, part, edition, year
      when /^(?<publisher>[A-Z\/]+)\s(?<stage>#{STAGE})\s(?<number>\w+)[.-](?<part>[[:alnum:].-]+)[\/\s_]ED(?<edition>[\d.]+),\s(?<year>\d{4})/o
        create_pubid(Regexp.last_match)

      # publisher, stage, number, draft, year, month
      when /^(?<publisher>[A-Z\/]+)\s(?<number>\w+)\/(?<stage>#{STAGE})[\/_]D(?<draft>[\w.]+),\s(?<month>\w+)\s(?<year>\d{4})/o
        create_pubid(Regexp.last_match)

      # number, part, draft, year, month
      when /(\w+)[.-]([[:alnum:].]+)[\/\s_]D([\d.]+)(?:,?\s|_)([[:alpha:]]+)[\s_]?(\d{4})/
        PubId.new(publisher: "IEEE", number: $1, part: sp($2), draft: dn($3), year: $5, month: mn($4))

      # number, corrigendum, draft, year, month
      when /^(\w+)-\d{4}[\/_]Cor\s?(\d)[\/_]D([\w.]+),\s(\w+)\s(\d{4})/
        PubId.new(publisher: "IEEE", number: $1, corr: $2, draft: dn($3), month: mn($4), year: $5)

      # publisher, number, corrigendum, draft, year
      when /^(?<publisher>[A-Z\/]+)#{APPROV}(?:\sDraft)?\sStd\s(?<number>\w+)(?:-\d{4})?[\/_]Cor\s?(?<corr>\d)\/D(?<draft>[\d\.]+),\s\w+\s(?<year>\d{4})/o
        create_pubid(Regexp.last_match)

      # publisher, number, part, rev, corrigendum, draft
      when /^([A-Z\/]+)\s(\w+)\.(\w+)-\d{4}-Rev\/Cor(\d)\/D([\d.]+)/
        PubId.new(publisher: $1, number: $2, part: $3, rev: "", corr: $4, draft: dn($5))

      # publisher, number, part, corrigendum, draft
      when /^(?<publisher>[A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(?<number>\w+)\.(?<part>[\w.]+)\/[Cc]or\s?(?<corr>\d)\/D(?<draft>[\w\.]+)/o,
           /^(?<publisher>[A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(?<number>\w+)\.(?<part>\w+)-\d{4}\/Cor\s?(?<corr>\d)[\/_]D(?<draft>[\d\.]+)/o
        create_pubid(Regexp.last_match)

      # publisher, number, part, corrigendum, year
      when /^(?<publisher>[A-Z\/]+)#{STD}\s(?<number>\w+)[.-](?<part>[\w.]+)[:-]\d{4}[\/-]Cor[\s.]?(?<corr>\d)[:-](?<year>\d{4})/o
        create_pubid(Regexp.last_match)

      # publisher, number, part, draft, year
      when /^(?<publisher>[A-Z\/]+)(?:\sActive)?#{APPROV}(?:\sDraft)?#{STD}\s(?<number>\w+)[.-](?<part>[[:alnum:]\.]+)(?:\s?\/\s?|_|,\s|-)D(?<draft>[\w\.]+)\s?,?\s\w+(?:\s\d{1,2},)?\s?(?<year>\d{2,4})/o,
           /^(?<publisher>[A-Z\/]+)#{STD}\s(?<number>\w+)[.-](?<part>[\w.-]+)[\/\s]D(?<draft>[\w.]*)(?:-|,\s?\w+\s|\s\w+:|,\s)(?<year>\d{4})/o,
           /^(?<publisher>[\w\/]+)(?:\sActive)?#{APPROV}(?:\sDraft)?#{STD}\s(?<number>\w+)[.-](?<part>[[:alnum:]\.]+)\sDraft\s(?<draft>[\w\.]+),\s\w+\s(?<year>\d{4})/o
        create_pubid(Regexp.last_match)

      # publisher, approval, number, draft, year
      when /^(?<publisher>[A-Z\/]+)#{APPROVAL}(?:\sDraft)?#{STD}\s(?<number>[[:alnum:]]+)\s?[\/_]\s?D(?<draft>[\w\.]+),?\s\w+\s(?<year>\d{2,4})/o,
           /^(?<publisher>[A-Z\/]+)\s(?<number>\w+)\/D(?<draft>[\d.]+),\s\w+[\s_](?<year>\d{4})(?:\s-\s\(?|_)?#{APPROVAL}/o
        create_pubid(Regexp.last_match)

      # publisher, number, part, rev, draft
      when /^(?<publisher>[A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(?<number>\w+)\.(?<part>[\w.]+)[-\s\/]?REV-?(?<rev>\w+)\/D(?<draft>[\d.]+)/o,
           /^(?<publisher>[A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(?<number>\w+)\.(?<part>[\w.]+)-REV\/D(?<draft>[\d.]+)/o
        create_pubid(Regexp.last_match)

      # publisher, number, part, rev, year
      when /^(?<publisher>[A-Z\/]+)#{APPROV}(?:\sDraft)?\sStd\s(?<number>\w+)\.(?<part>\d+)\/rev(?<rev>\d+),\s\w+\s(?<year>\d+)/o
        create_pubid(Regexp.last_match)

      # publisher, stage, number, draft, year
      when /^(?<publisher>[\w\/]+)\s#{STAGE}\s(?<number>[[:alnum:]]+)[\/_]D(?<draft>[\w.]+),(?:\s\w+)?\s(?<year>\d{4})/o
        create_pubid(Regexp.last_match)

      # publisher, stage, number, part, year, month
      when /^(?<publisher>[A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(?<number>\w+)[.-](?<part>[[:alnum:].-]+)(?:[\/_-]|,\s)#{STAGE},?\s(?<month>\w+)\s(?<year>\d{4})/o,
           /^(?<publisher>[A-Z\/]+)\s(?<stage>#{STAGE})\s(?<number>\w+)[.-](?<part>\w+),\s(?<month>\w+)\s(?<year>\d{4})/o
        create_pubid(Regexp.last_match)

      # publisher, number, part, edition, year, month
      when /^(?<publisher>[A-Z\/]+)\s(?<number>\w+)[.-](?<part>[\w.-]+)[\/\s]ED(?<edition>[\d+]),\s(?<month>\w+)\s(?<year>\d{4})/
        create_pubid(Regexp.last_match)

      # publisher, stage, number, part, year
      when /^(?<publisher>[A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(?<number>\w+)[.-](?<part>\d+)[\/_-]#{STAGE},?\s\w+\s(?<year>\d{4})/o,
           /^(?<publisher>[A-Z\/]+)\s(?<number>\w+)-(?<part>\d+)[\/-]#{STAGE}(?:_|,\s|-)\w+\s?(?<year>\d{4})/o,
           /^(?<publisher>[A-Z\/]+)\s(?<number>\w+)[.-](?<part>\d+)[\/-_]#{STAGE}[\s-](?<year>\d{4})/o,
           /^(?<publisher>[A-Z\/]+)\s(?<stage>#{STAGE})\s(?<number>\w+)-(?<part>[\w-]+),\s(?<year>\d{4})/o
        create_pubid(Regexp.last_match)

      # publisher, stage, number, year, month
      when /^(?<publisher>[A-Z\/]+)\s#{STAGE}\s(?<number>\w+)(?:\s\g<stage>)?,\s(?<month>\w+)\s(?<year>\d{4})/o,
           /^(?<publisher>[A-Z\/]+)\s(?<number>[[:alnum:]]+)(?:\s|_|\/\s?)?#{STAGE},?\s(?<month>\w+)\s(?<year>\d{4})/o
        create_pubid(Regexp.last_match)

      # publisher, stage, number, part, draft
      when /^(?<publisher>[A-Z\/]+)[.-](?<part>[[:alnum:].-]+)[\/_]D(?<draft>[[:alnum:].]+)[\/_]#{STAGE}/o,
           /^(?<number>\w+)[.-](?<part>[[:alnum:].]+)[\/\s_]D(?<draft>[\d.]+)_(?<stage>#{STAGE})/o
        create_pubid(Regexp.last_match)

      # publisher, stage, number, year
      when /^(?<publisher>[A-Z\/]+)\s#{STAGE}\s(?<number>\w+)(?:,\s\w+\s|:)(?<year>\d{4})/o,
           /^(?<publisher>[A-Z\/]+)\s(?<number>\w+)(?:\/|,\s)(?<stage>#{STAGE})-(?<year>\d{4})/o
        create_pubid(Regexp.last_match)

      # publisher, stage, number, part
      when /^(?<publisher>[A-Z\/]+)\s(?<number>\w+)-(?<part>[\w-]+)[\s-]#{STAGE}/o,
           /^(?<publisher>[A-Z\/]+)\s(?<number>\w+)-#{STAGE}-(?<part>\w+)/o,
           /^(?<publisher>[A-Z\/]+)\s#{STAGE}\s(?<number>\w+)[.-](?<part>[[:alnum:].-]+)/o
        create_pubid(Regexp.last_match)

      # publisher, number, corrigendum, year
      when /^(?<publisher>[A-Z\/]+)#{STD}\s(?<number>\w+)-\d{4}\/Cor\s?(?<corr>\d)-(?<year>\d{4})/o
        create_pubid(Regexp.last_match)

      # publisher, number, rev, draft
      when /^(?<publisher>[A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(?<number>\w+)-REV\/D(?<draft>[\d.]+)/o
        create_pubid(Regexp.last_match)

      # publisher, number, part, year, month
      when /^(?<publisher>[A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(?<number>\w+)-(?<part>[\w-]+),\s(?<month>\w+)\s?(?<year>\d{4})/o,
        /^(?<publisher>[A-Z\/]+)\sStd\s(?<number>\w+)\.(?<part>\w+)-\d{4}\/INT,?\s(?<month>\w+)\.?\s(?<year>\d{4})/
        create_pubid(Regexp.last_match)

      # publisher, number, part, amendment, year
      when /^(?<publisher>[A-Z\/]+)#{STD}\s(?<number>\w+)-(?<part>\w+)[:-](?<year>\d{4})\/Amd(?:\s|.\s?)?(?<amd>\d)/o
        create_pubid(Regexp.last_match)

      # publisher, number, part, year, redline
      when /^(?<publisher>[A-Z\/]+)#{STD}\s(?<number>\w+)[.-](?<part>[\w.]+)[:-](?<year>\d{4}).*?\s-\s(?<redline>Redline)/o,
           /^(?<publisher>[A-Z\/]+)#{STD}\s(?<number>\w+)[.-](?<part>[\w.-]+):(?<year>\d{4}).*?\s-\s(?<redline>Redline)/o
        create_pubid(Regexp.last_match)

      # publisher, number, part, year
      when /^(?<publisher>[A-Z\/]+)\s(?<number>\w+)-(?<part>\d{1,3}),\s\w+\s(?<year>\d{4})/,
        /^(?<publisher>[A-Z\/]+)#{STD}\s(?<number>\w+)[.-](?!(?:19|20)\d{2}\D)(?<part>[\w.]+)(?:,\s\w+\s|-|:|,\s|\.|:)(?<year>\d{4})/o,
        /^(?<publisher>[A-Z\/]+)#{STD}\s(?<number>\w+)[.-](?!(?:19|20)\d{2}\D)(?<part>[\w.-]+)(?:,\s\w+\s|:|,\s|\.|:)(?<year>\d{4})/o,
        /^(?<publisher>[A-Z\/]+)#{STD}\sNo(?:\.?\s|\.)(?<number>\w+)\.(?<part>\d+)\s?-(?:\w+\s)?(?<year>\d{4})/o
        create_pubid(Regexp.last_match)

      # publisher, number, edition, year
      when /^([A-Z\/]+)\s(\w+)\s(\w+)\sEdition,\s\w+\s(\d+)/,
           /^([A-Z\/]+)\s(\w+)[\/_]ED([\d.]+),\s(\d{4})/
        PubId.new(publisher: $1, number: $2, edition: en($3), year: $4)

      # publisher, number, part, conformance, draft
      when /^(?<publisher>[A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(?<number>\w+)\.(?<part>[[:alnum:].]+)[\/-]Conformance(?<conformance>\d+)[\/_]D(?<draft>[\w\.]+)/o
        create_pubid(Regexp.last_match)

      # publisher, number, part, conformance, year
      when /^(?<publisher>[A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(?<number>\w+)\.(?<part>[[:alnum:].]+)\s?\/\s?Conformance(?<conformance>\d+)-(?<year>\d{4})/o
        create_pubid(Regexp.last_match)

      # publisher, number, part, draft
      when /^(?<publisher>[A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(?<number>\w+)\.(?<part>[[:alnum:].]+)[^\/]*\/D(?<draft>[[:alnum:]\.]+)/o,
           /^(?<publisher>[A-Z\/]+)\s(?<number>\w+)[.-](?<part>[[:alnum:]-]+)[\s_]D(?<draft>[\d.]+)/,
           /^(?<publisher>[A-Z\/]+)\s(?<number>\w+)-(?<part>\w+)\/D(?<draft>[\w.]+)/
        create_pubid(Regexp.last_match)

      # number, part, draft, year
      when /^(?<number>\w+)[.-](?<part>[[:alnum:].-]+)(?:\/|,\s|_)D(?<draft>[\d.]+),?\s(?:\w+,?\s)?(?<year>\d{4})/
        create_pubid(Regexp.last_match)

      # publisher, number, draft, year, month
      when /^(?<publisher>[A-Z\/]+)\s(?<number>\w+)[\/_]D(?<draft>[\d.]+),\s(?<month>\w+)\s(?<year>\d{4})/
        create_pubid(Regexp.last_match)

      # publisher, number, draft, year
      when /^(?<publisher>[\w\/]+)(?:\sActive)?#{APPROV}(?:\sDraft)?#{STD}\s(?<number>[[:alnum:]]+)\s?[\/_]\s?D(?<draft>[\w\.-]+),?\s(?:\w+\s)?(?<year>\d{2,4})/o,
        /^(?<publisher>[\w\/]+)(?:\sActive)?#{APPROV}(?:\sDraft)?#{STD}\s(?<number>[[:alnum:]]+)\/?D?(?<draft>[\d\.]+),?\s\w+\s(?<year>\d{4})/o,
        /^(?<publisher>[A-Z\/]+)\s(?<number>\w+)\/Draft\s(?<draft>[\d.]+),\s\w+\s(?<year>\d{4})/,
        /^(?<publisher>[A-Z\/]+)\sStd\s(?<number>\w+)-(?<year>\d{4})\sDraft\s(?<draft>[\d.]+)/
        create_pubid(Regexp.last_match)

      # publisher, approval, number, draft
      when /^(?<publisher>[A-Z\/]+)#{APPROVAL}(?:\sDraft)?#{STD}\s(?<number>[[:alnum:]]+)[\/_]D(?<draft>[\w.]+)/o
        create_pubid(Regexp.last_match)

      # number, draft, year
      when /^(?<number>\w+)\/D(?<draft>[\w.+]+),?\s\w+,?\s(?<year>\d{4})/
        create_pubid(Regexp.last_match)

      # number, rev, draft
      when /^(?<number>\w+)-REV\/D(?<draft>[\d.]+)/o
        create_pubid(Regexp.last_match)

      # publisher, number, draft
      when /^(?<publisher>[\w\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(?<number>[[:alnum:]]+)[\/_]D(?<draft>[\w.]+)/o
        create_pubid(Regexp.last_match)

      # publisher, number, year, month
      when /^(?<publisher>[A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(?<number>\w+)(?:-\d{4})?,\s(?<month>\w+)\s(?<year>\d{4})/o
        create_pubid(Regexp.last_match)

      # publisher, number, year, redline
      when /^(?<publisher>[A-Z\/]+)#{STD}\s(?<number>\w+)[:-](?<year>\d{4}).*?\s-\s(?<redline>Redline)/o
        create_pubid(Regexp.last_match)

      # publisher, number, year
      when /^(?<publisher>[A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(?<number>\w+)(?:-|:|,\s(?:\w+\s)?)(?<year>\d{2,4})/o,
           /^(?<publisher>\w+)#{APPROV}(?:\sDraft)?\sStd\s(?<number>\w+)\/\w+\s(?<year>\d{4})/o,
           /^(?<publisher>[\w\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(?<number>\w+)\/FCD-\w+(?<year>\d{4})/o,
           /^(?<publisher>\w+)#{STD}\sNo(?:\.?\s|\.)(?<number>\w+)\s?(?:-|,\s)(?:\w+\s)?(?<year>\d{4})/o,
           /^(?<publisher>[A-Z\/]+)\sStd\s(?<number>\w+)\/INT-(?<year>\d{4})/,
          /^(?<publisher>ANSI\/\sIEEE)#{STD}\s(?<number>\w+)-(?<year>\d{4})/o
        create_pubid(Regexp.last_match)

      # publisher, number, part
      when /^(?<publisher>[A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(?<number>\w+)[.-](?<part>[\d.]+)/o
        create_pubid(Regexp.last_match)

      # number, part, draft
      when /^(?<number>\w+)\.(?<part>[\w.]+)\/D(?<draft>[\w.]+)/
        create_pubid(Regexp.last_match)

      # number, part, year
      when /^(\d{2})\sIRE\s(\w+)[\s.](\w+)/ # "IRE #{$2}-#{$3}.#{yn $1}"
        PubId.new(publisher: "IRE", number: $2, part: $3, year: yn($1))
      when /^(\w+)\.(\w+)-(|d{4})/ then PubId.new(publisher: "IEEE", number: $1, part: $2, year: $3)

      # number, year
      when /^(\w+)-(\d{4})\D/ then PubId.new(publisher: "IEEE", number: $1, year: $2)

      # publisher, number
      when /^(?<publisher>[A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}(?:\sNo\.?)?\s(?<number>\w+)/o
        create_pubid(Regexp.last_match)

      else
        Util.warn %{Use stdnumber "#{stdnumber}" for normtitle "#{normtitle}"}
        PubId.new(publisher: "IEEE", srd: true, number: stdnumber)
      end
    rescue ArgumentError => e
      e
    end

    def create_pubid(regex_match)
      args = regex_match.named_captures
      PubId.new(
        publisher: args["publisher"] || "IEEE",
        std: !!args["std"],
        number: args["number"],
        part: part(args),
        draft: dn(args["draft"]),
        year: yn(args["year"]),
        month: mn(args["month"]),
        stage: args["stage"],
        rev: args["rev"],
        corr: args["corr"],
        edition: en(args["edition"]),
        amd: args["amd"],
        redline: args["redline"],
        approval: args["approval"],
        status: args["status"]
      )
    end

    def part(args)
      return unless args.key?("part")

      [args["part"], args["conformance"]].compact.join("-")
    end

    # replace subpart's delimiter
    #
    # @param parts [Strong]
    #
    # @return [String]
    def sp(parts)
      parts # .gsub ".", "-"
    end

    #
    # Convert 2 digits year to 4 digits
    #
    # @param [String] year
    #
    # @return [String, nil] nil if string's length isn't 2 or 4
    #
    def yn(year)
      return year if year.nil? || year.size == 4

      y = Date.today.year.to_s[2..4].to_i + 1
      case year.to_i
      when 0...y then "20#{year}"
      when y..99 then "19#{year}"
      end
    end

    #
    # Return number of month
    #
    # @param [String] month monthname
    #
    # @return [String] 2 digits month number
    #
    def mn(month)
      return if month.nil?

      n = Date::ABBR_MONTHNAMES.index(month) || Date::MONTHNAMES.index(month)
      return month unless n

      n.to_s.rjust 2, "0"
    end

    #
    # Convert edition name to number
    #
    # @param [Strin] edition
    #
    # @return [String, Integer]
    #
    def en(edition)
      case edition
      when "First" then 1
      when "Second" then 2
      else edition
      end
    end

    def dn(draftnum)
      draftnum && draftnum.sub(/^\./, "").gsub("-", ".")
    end

    extend RawbibIdParser
  end
end
