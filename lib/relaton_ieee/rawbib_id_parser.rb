require "relaton_ieee/pub_id"

module RelatonIeee
  module RawbibIdParser
    STAGES = 'DIS\d?|PSI|FCD|FDIS|CD\d?|Pub2|CDV'.freeze
    APPROVAL = '(?:\s(Unapproved|Approved))'.freeze
    APPROV = '(?:\s(?:Unapproved|Approved))?'.freeze
    STD = "(?:\s(?i)Std\.?(?-i))?".freeze

    def parse(normtitle)
      case normtitle
      # when /^(\d+\/D\d),\s\w+\s(\d+)/ then "IEEE #{$1}.#{$2}"
      # when /^(\w+)-(\d{4})\sIEEE/ then "IEEE #{$1}.#{$2}}"
      # when "2012 NESC Handbook, Seventh Edition" then "NESC HBK ED7.2012"
      # when "2017 NESC(R) Handbook, Premier Edition" then "NESC HBK ED1.2017"
      # when "2017 National Electrical Safety Code(R) (NESC(R)) - Redline" then "NESC C2R.2017"
      # when "2017 National Electrical Safety Code(R) (NESC(R))" then "NESC C2.2017"
      # when /^(\d+HistoricalData)-(\d{4})/ then "IEEE #{$1}.#{$2}"
      # when /^(\d{2})\sIRE\s(\d+)[\.\s](\w+)/ then "IRE #{$2}-#{$3}.19#{$1}"
      # when /^(\d+-\d\/D\d),\s(\d{4})/ then "IEC/IEEE #{$1}.#{$2}"
      # when /^(\d+)\.(\w+)\sBattery\sLife\sImprovement/ then "IEEE #{$1}-#{$2}"
      # when /^(\d+)\.(\w+)\.(\w+)\/(D\d),\s\w+\s(\d{4})/ then "IEEE #{$1}-#{$2}-#{$3}/#{$4}.#{$5}"
      # when /^(\d+)\.(\w+)-(\d{4})\s\(Amendment/ then "IEEE #{$1}-#{$2}.#{$3}"
      # when /^(\d+)\.(\w+)\/(D\d+),\s\w+\s(\d{4})/ then "IEEE #{$1}-#{$2}/#{$3}.#{$4}"
      # when /^(\d+)\.(\w+)-(\d{4})\/(Cor\s\d)-(\d{4})/ then "IEEE #{$1}-#{$2}.#{$3}/#{$4}.#{$5}"
      # when "A.I.E.E. No. 15 May-1928" then "AIEE 15.1928"
      # when /^([A-Z\/]{3,})\s[Nn]o(?:\.?\s|\.)(\w+)(?:\s\(105\))?(?:\s?-|,?\s)(?:\w+\s)?(\d{4})/
      #   "#{$1} #{$2}.#{$3}"
      # when /^([A-Z\/]{3,})\sNo\s(\w+)\.(\d+)-(\d{4})/ then "#{$1} #{$2}-#{$3}.#{$4}"
      # when "AIEE Nos 72 and 73 - 1932" then "AIEE 72_73.1932"
      when "IEEE Std P1073.1.3.4/D3.0" then PubId.new(publisher: "IEEE", number: "P11073", part: "00101").to_s # "IEEE P11073-00101"
      # when "P1073.1.3.4/D3.0" then PubId.new(publisher: "IEEE", number: "P1073", part: "1-3-4", draft: "3.0").to_s # "IEEE P1073-1-3-4/D3.0"
      when "IEEE P1073.2.1.1/D08" then PubId.new(publisher: "ISO/IEEE", number: "P1073", part: "2-1-1", draft: "08").to_s # "ISO/IEEE P1073-2-1-1/D08"
      when "IEEE P802.1Qbu/03.0, July 2015" # "IEEE P802.1Qbu/D3.0.2015"
        PubId.new(publisher: "IEEE", number: "P802", part: "1Qbu", draft: "3.0", year: "2015").to_s
      when "IEEE P11073-10422/04, November 2015" # "IEEE P11073-10422/D04.2015"
        PubId.new(publiisher: "IEEE", number: "P11073", part: "10422", draft: "04", year: "2015").to_s
      when "IEEE P802.11aqTM/013.0 October 2017" # "IEEE P802-11aqTM/D13.0.2017"
        PubId.new(publisher: "IEEE", number: "P802", part: "11aqTM", draft: "13.0", year: "2017").to_s
      when "IEEE P844.3/C22.2 293.3/D0, August 2018" # "IEEE P844-3/C22.2-293.3/D0.2018"
        PubId.new([{ publisher: "IEEE", number: "P844", part: "3" },
                   { number: "C22.2", part: "293.3", dtaft: "0", year: "2018" }]).to_s
      when "IEEE P844.3/C22.2 293.3/D1, November 2018" # "IEEE P844.3/C22.2 293.3/D1.2018"
        PubId.new([{ publisher: "IEEE", number: "P844", part: "3" },
                   { number: "C22.2", part: "293.3", draft: "1", year: "2018" }]).to_s
      when "AIEE No 431 (105) -1958" then PubId.new(publisher: "AIEE", number: "431", year: "1958").to_s # "AIEE 431.1958"
      when "IEEE 1076-CONC-I99O" then PubId.new(publisher: "IEEE", number: "1076", year: "199O").to_s # "IEEE 1076.199O"
      when "IEEE Std 960-1993, IEEE Std 1177-1993" # "IEEE 960/1177.1993"
        PubId.new([{ publisher: "IEEE", number: "960" }, { number: "1177", year: "1993" }]).to_s
      when "IEEE P802.11ajD8.0, August 2017" # "IEEE P802-11aj/D8.0.2017"
        PubId.new(publisher: "IEEE", number: "P802", part: "11aj", draft: "8.0", year: "2017").to_s
      when "IEEE P802.11ajD9.0, November 2017" # "IEEE P802-11aj/D9.0.2017"
        PubId.new(publisher: "IEEE", number: "P802", part: "11aj", draft: "9.0", year: "2017").to_s
      when "ISO/IEC/IEEE P29119-4-DISMay2013" # "ISO/IEC/IEEE DIS P29119-4.2013"
        PubId.new(publisher: "ISO/IEC/IEEE", stage: "DIS", number: "P29119", part: "4", year: "2013").to_s
      when "IEEE-P15026-3-DIS-January 2015" # "IEEE DIS P15026-3.2015"
        PubId.new(publisher: "IEEE", stage: "DIS", number: "P15026", year: "2015").to_s
      when "ANSI/IEEE PC63.7/D rev17, December 2014" # "ANSI/IEEE PC63-7/D/REV-17.2014"
        PubId.new(publusher: "ANSI/IEEE", number: "PC63", part: "7", draft: "", rev: "17", year: "2014").to_s
      when "IEC/IEEE P62271-37-013:2015 D13.4" # "IEC/IEEE P62271-37-013/D13.4.2015"
        PubId.new(publisher: "IEC/IEEE", number: "P62271", part: "37-013", draft: "13.4", year: "2015").to_s
      when "PC37.30.2/D043 Rev 18, May 2015" # "IEEE PC37-30-2/D043/REV-18.2015"
        PubId.new(publisher: "IEEE", number: "PC37", part: "30-2", draft: "043", rev: "18", year: "2015").to_s
      when "IEC/IEEE FDIS 62582-5 IEC/IEEE 2015" # "IEC/IEEE FDIS 62582-5.2015"
        PubId.new(publisher: "IEC/IEEE", stage: "FDIS", number: "62582", part: "5", year: "2015").to_s
      when "ISO/IEC/IEEE P15289:2016, 3rd Ed FDIS/D2" # "ISO/IEC/IEEE FDIS P15289/E3/D2.2016"
        PubId.new(publisher: "ISO/IEC/IEEE", stage: "FDIS", number: "P15289", part: "", edition: "3", draft: "2", year: "2016").to_s
      when "IEEE P802.15.4REVi/D09, April 2011 (Revision of IEEE Std 802.15.4-2006)"
        PubId.new(publisher: "IEEE", number: "P802", part: "15.4", rev: "i", draft: "09", year: "2013", month: "04", approval: true).to_s
      when "Draft IEEE P802.15.4REVi/D09, April 2011 (Revision of IEEE Std 802.15.4-2006)"
        PubId.new(publisher: "IEEE", number: "P802", part: "15.4", rev: "i", draft: "09", year: "2011", month: "04").to_s

      # drop all with <standard_id>0</standard_id>
      when "IEEE Std P1671/D5, June 2006" then "IEEE P1671/D5 June 2006"
      when "IEEE Std PC37.100.1/D8, Dec 2006" then "IEEE Std PC37-100-1/D8 Dec 2006"
      when "IEEE Unapproved Draft Std P1578/D17, Mar 2007" then "IEEE Unapproved Draft Std P1578/D17, Mar 2007"
      when "IEEE Approved Draft Std P1115a/D4, Feb 2007" then "IEEE Approved Draft Std P1115a/D4, Feb 2007"
      when "IEEE Std P802.16g/D6, Nov 06" then "IEEE Std P802.16g/D6, Nov 06"
      when "IEEE Unapproved Draft Std P802.1AB/REVD2.2, Dec 2007" then "IEEE P802.1AB/REV/D2.2.2007"
      when "IEEE Unapproved Draft Std P1588_D2.2, Jan 2008" then "IEEE Unapproved Draft Std P1588_D2.2, Jan 2008"
      when "IEEE Unapproved Std P90003/D1, Feb 2007.pdf" then "IEEE Unapproved Std P90003/D1, Feb 2007"
      when "IEEE Unapproved Draft Std PC37.06/D10 Dec 2008" then "IEEE Unapproved Draft Std PC37.06/D10 Dec 2008"
      when "IEEE P1451.2/D20, February 2011" then "IEEE P1451.2/D20, February 2011"
      when "IEEE Std P1641.1/D3, July 2006",
           "IEEE P802.1AR-Rev/D2.2, September 2017 (Draft Revision of IEEE Std 802.1AR\u20132009)",
           "IEEE Std 108-1955; AIEE No.450-April 1955",
           "IEEE Std 85-1973 (Revision of IEEE Std 85-1965)",
           "IEEE Std 1003.1/2003.l/lNT, March 1994 Edition" then nil

      # publisher1, number1, part1, publisher2, number2, part2, draft, year
      when /^(\w+)\s(\w+)[-.](\d+)\/(\w+)\s(\w+)[-.](\d+)_D([\d.]+),\s\w+\s(\d{4})/
        # "#{$1} #{$2}-#{$3}/#{$4} #{$5}-#{$6}/D#{$7}.#{$8}"
        PubId.new([{ publisher: $1, number: $2, part: $3 },
                   { publisher: $4, number: $5, part: $6, draft: $7, year: $8 }]).to_s

      # publisher1, number1, part1, number2, part2, draft, year, month
      when /^([A-Z\/]+)\s(\w+)[.-]([\w.-]+)\/(\w+)[.-]([[:alnum:].-]+)[\/_]D([\w.]+),\s(\w+)\s(\d{4})/
        PubId.new([{ publisher: $1, number: $2, part: $3 }, { number: $4, part: $5, draft: $6, year: $8, month: mn($7) }]).to_s

      # publisher, approval, number, part, corrigendum, draft, year
      when /^(\w+)#{APPROVAL}(?:\sDraft)?\sStd\s(\w+)\.(\d+)-\d{4}[^\/]*\/Cor\s?(\d)\/(D[\d\.]+),\s(?:\w+\s)?(\d{4})/o
        # "#{$1}#{$2} #{$3}-#{sp $4}/Cor#{$5}/D#{$6}.#{$7}"
        PubId.new(publisher: $1, approval: $2, number: $3, part: sp($4), corr: $5, draft: $6, year: $7).to_s

      # publisher, number, part, corrigendum, draft, year, month
      when /^(\w+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)\.(\w+)-\d{4}\/Cor\s?(\d(?:-\d+x)?)[\/_]D([\d\.]+),\s?(\w+)\s(\d{4})/o
        # "#{$1} #{$2}-#{$3}/Cor#{$4}/D#{$5}.#{$7}-#{mn $6}"
        PubId.new(publisher: $1, number: $2, part: $3, corr: $4, draft: $5, month: mn($6), year: $7).to_s

      # publidsher1, number1, year1 publisher2, number2, draft, year2
      when /^(\w+)\s(\w+)-(\d{4})\/([A-Z]+)\s([[:alnum:]]+)_D([\w.]+),\s(\d{4})/
        # "#{$1} #{$2}.#{$3}/#{$4} #{$5}/D#{$6}.#{$7}"
        PubId.new([{ publisher: $1, number: $2, year: $3 }, { publisher: $4, number: $5, draft: $6, year: $7 }]).to_s

      # publidsher1, number1, publisher2, number2, draft, year
      when /^(\w+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)\/([A-Z]+)\s([[:alnum:]]+)_D([\d\.]+),\s\w+\s(\d{4})/o,
           /^(\w+)\s(\w+)\sand\s([A-Z]+)(?:\sGuideline)?\s([[:alnum:]]+)\/D([\d\.]+),\s\w+\s(\d{4})/o
        # "#{$1} #{$2}/#{$3} #{$4}/D#{$5}.#{$6}"
        PubId.new([{ publisher: $1, number: $2 }, { publisher: $3, number: $4, draft: $5, year: $6 }]).to_s

      # publidsher1, number1, part, publisher2, number2, year
      when /^([A-Z\/]+)\s(\w+)\.(\d+)_(\w+)\s(\w+),\s(\d{4})/ # "#{$1} #{$2}-#{$3}/#{$4} #{$5}.#{$6}"
        PubId.new([{ publisher: $1, number: $2, part: $3 }, { publisher: $4, number: $5, year: $6 }]).to_s

      # publisher, number1, part1, number2, part2, draft
      when /^([A-Z\/]+)\s(\w+)[.-](\d+)\/(\w+)\.(\d+)[\/_]D([\d.]+)/ # "#{$1} #{$2}-#{$3}/#{$4}-#{$5}/D#{$6}"
        PubId.new([{ publisher: $1, number: $2, part: $3 }, { number: $4, part: $5, draft: $6 }]).to_s

      # publidsher, number1, part1, number2, part2, year
      when /^(\w+)\sStd\s(\w+)\.(\w+)\/(\w+)\.(\w+)\/INT\s\w+\s(\d{4})/
        # "#{$1} #{$2}-#{$3}/#{$4}-#{$5}.#{$6}"
        PubId.new([{ publisher: $1, number: $2, part: $3 }, { number: $4, part: $5, year: $6 }]).to_s

      # publisher, number, part, corrigendum, draft, year
      when /^(\w+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)[.-]([\d-]+)\/Cor\s?(\d)[\/_]D([\d\.]+),\s(?:\w+\s)?(\d{4})/o,
           /^(\w+)\s(\w+)[.-](\d+)-\d{4}\/Cor\s?(\d)(?:-|,\s|\/)D([\d.]+),?\s\w+\s(\d{4})/,
           /^(\w+)\s(\w+)\.([[:alnum:].]+)[-_]Cor[\s-]?(\d)\/D([\d.]+),?\s\w+\s(\d{4})/
        # "#{$1} #{$2}-#{sp $3}/Cor#{$4}/D#{$5}.#{$6}"
        PubId.new(publisher: $1, number: $2, part: sp($3), corr: $4, draft: $5, year: $6).to_s
      when /^(\w+)\s(\w+)\.(\d+)-\d{4}\/Cor(\d)-(\d{4})\/D([\d.]+)/ # "#{$1} #{$2}-#{$3}/Cor#{$4}/D#{$6}.#{$5}"
        PubId.new(publisher: $1, number: $2, part: $3, corr: $4, draft: $6, year: $5).to_s

      # publisher, status, number, part, draft, year, month
      when /^(\w+)(\sActive)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)[.-]([[:alnum:]\.]+)\s?[\/_]D([\w\.]+),?\s(\w+)(?:\s\d{1,2},)?\s?(\d{2,4})/o
        # "#{$1}#{$2} #{$3}-#{sp $4}/D#{$5}.#{yn $7}-#{mn $6}"
        PubId.new(publisher: $1, status: $2, number: $3, part: sp($4), draft: $5, year: $7, month: mn($6)).to_s

      # publisher, approval, number, part, draft, year, month
      when /^(\w+)(?:\sActive)?#{APPROVAL}(?:\sDraft)?#{STD}\s(\w+)[.-]([[:alnum:]\.]+)\s?[\/_]D([\w\.-]+),?\s(\w+)(?:\s\d{1,2},)?\s?(\d{2,4})/o
        # "#{$1}#{$2} #{$3}-#{sp $4}/D#{$5}.#{yn $7}-#{mn $6}"
        PubId.new(publisher: $1, approval: $2, number: $3, part: sp($4), draft: $5, year: $7, month: mn($6)).to_s
      when /^([A-Z\/]+)\s(\w+)\.([\w.]+)\/D([\w.]+),?\s(\w+)[\s_](\d{4})(?:\s-\s\(|\s\(|_)(Unapproved|Approved)/
        PubId.new(publisher: $1, number: $2, part: $3, draft: $4, year: $6, month: mn($5), approval: $7).to_s

      # publisher, approval, number, draft, year, month
      when /^([A-Z\/]+)\s(\w+)\/D([\w.]+),\s(\w+)\s(\d{4})\s-\s\(?(Approved|Unapproved)/
        PubId.new(publisher: $1, number: $2, draft: $3, year: $5, month: mn($4), approval: $6).to_s

      # publisher, approval, number, part, draft, year
      when /^(\w+)#{APPROVAL}(?:\sDraft)?#{STD}\s(\w+)[.-]([\w.]+)\s?[\/_\s]D([\w\.]+),?\s\w+\s?(\d{4})/o
        # "#{$1}#{$2} #{$3}-#{sp $4}/D#{$5}.#{$6}"
        PubId.new(publisher: $1, approval: $2, number: $3, part: sp($4), draft: $5, year: $6).to_s
      when /^(\w+)\s(\w+)\.([\w.]+)\/D([\d.]+),?\s\w+[\s_](\d{4})(?:\s-\s\(|_|\s\()?#{APPROVAL}/o
        # "#{$1} #{$6} #{$2}-#{sp $3}/D#{$4}.#{$5}"
        PubId.new(publisher: $1, number: $2, part: sp($3), draft: $4, year: $5, approval: $6).to_s

      # number, part, corrigendum, draft, year
      when /^(\w+)\.([\w.]+)-\d{4}[_\/]Cor\s?(\d)\/D([\w.]+),?\s\w+\s(?:\d{2},\s)?(\d{4})/
        # "IEEE #{$1}-#{sp $2}/Cor#{$3}/D#{$4}.#{$5}"
        PubId.new(number: $1, part: sp($2), corr: $3, draft: $4, year: $5).to_s

      # publisher, approval, number, part, draft
      when /^(\w+)\s(\w+)\.(\d+)\/D([\d.]+)\s\([^)]+\)\s-#{APPROVAL}/o
        # "#{$1} #{$5} #{$2}-#{$3}/D#{$4}"
        PubId.new(publisher: $1, approval: $5, number: $2, part: $3, draft: $4).to_s

      # publisher, number, part1, rev, draft, part2
      when /^(\w+)#{STD}\s(\w+)\.([\d.]+)REV([a-z]+)_D([\w.]+)\sPart\s(\d)/o
        # "#{$1} #{$2}-#{sp $3}-#{$6}/REV-#{$4}/D#{$5}"
        PubId.new(publisher: $1, number: $2, part: "#{$3}-#{$6}", rev: $4, draft: $5).to_s

      # publisher, number, part, draft, year, month
      when /^([A-Z\/]+)#{STD}\s(\w+)[.-]([[:alnum:].]+)[\/\s_]D([\d.]+)(?:,?\s|_)([[:alpha:]]+)[\s_]?(\d{4})/o
        # "#{$1} #{$2}-#{sp $3}/D#{$4}.#{$6}-#{mn $5}"
        PubId.new(publisher: $1, number: $2, part: sp($3), draft: $4, year: $6, month: mn($5)).to_s

      # publisher, stage, number, part, draft, year
      when /^([\w\/]+)\s(#{STAGES})\s(\w+)-([[:alnum:]]+)[\/_\s]D([\d.]+),\s\w+\s(\d{4})/o
        # "#{$1} #{$2} #{$3}-#{sp $4}/D#{$5}.#{$6}"
        PubId.new(publisher: $1, stage: $2, number: $3, part: sp($4), draft: $5, year: $6).to_s

      # publisher, number, part, rev, draft, year, month
      when /^(\w+)\s(\w+)\.([\w.]+)-Rev\/D([\w.]+),\s(\w+)\s(\d{4})/
        # "#{$1} #{$2}-#{sp $3}/REV/D#{$4}.#{$6}-#{mn $5}"
        PubId.new(publisher: $1, number: $2, part: sp($3), rev: "", draft: $4, year: $6, month: mn($5)).to_s

      # publisher, number, part, rev, draft, year
      when /^(\w+)\s(\w+)\.([\d.]+)Rev(\w+)-D([\w.]+),\s\w+\s(\d{4})/
        # "#{$1} #{$2}-#{sp $3}/REV-#{$4}/D#{$5}.#{$6}"
        PubId.new(publisher: $1, number: $2, part: sp($3), rev: $4, draft: $5, year: $6).to_s

      # number, part, draft, year, month
      when /(\w+)[.-]([[:alnum:].]+)[\/\s_]D([\d.]+)(?:,?\s|_)([[:alpha:]]+)[\s_]?(\d{4})/
        PubId.new(publisher: "IEEE", number: $1, part: sp($2), draft: $3, year: $5, month: mn($4)).to_s

      # number, corrigendum, draft, year, month
      when /^(\w+)-\d{4}[\/_]Cor\s?(\d)[\/_]D([\w.]+),\s(\w+)\s(\d{4})/
        PubId.new(publisher: "IEEE", number: $1, corr: $2, draft: $3, month: mn($4), year: $5).to_s

      # publisher, number, corrigendum, draft, year
      when /^(\w+)#{APPROV}(?:\sDraft)?\sStd\s(\w+)(?:-\d{4})?[\/_]Cor\s?(\d)\/D([\d\.]+),\s\w+\s(\d{4})/o
        # "#{$1} #{$2}/Cor#{$3}/D#{$4}.#{$5}"
        PubId.new(publisher: $1, number: $2, corr: $3, draft: $4, year: $5).to_s

      # publisher, number, part, rev, corrigendum, draft
      when /^(\w+)\s(\w+)\.(\w+)-\d{4}-Rev\/Cor(\d)\/D([\d.]+)/
        # "#{$1} #{$2}-#{$3}/REV/Cor#{$4}/D#{$5}"
        PubId.new(publisher: $1, number: $2, part: $3, rev: "", corr: $4, draft: $5).to_s

      # publisher, number, part, corrigendum, draft
      when /^(\w+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)\.([\w.]+)\/[Cc]or\s?(\d)\/D([\w\.]+)/o,
           /^(\w+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)\.(\w+)-\d{4}\/Cor\s?(\d)[\/_]D([\d\.]+)/o
        # "#{$1} #{$2}-#{sp $3}/Cor#{$4}/D#{$5}"
        PubId.new(publisher: $1, number: $2, part: sp($3), corr: $4, draft: $5).to_s

      # publisher, number, part, corrigendum, year
      when /^(\w+)#{STD}\s(\w+)\.([\w.]+)-\d{4}\/Cor\s?(\d)-(\d{4})/o
        # "#{$1} #{$2}-#{$3}/Cor#{$4}.#{$5}"
        PubId.new(publisher: $1, number: $2, part: $3, corr: $4, year: $5).to_s

      # publisher, number, part, draft, year
      when /^([\w\/]+)(?:\sActive)?#{APPROV}(?:\sDraft)?#{STD}\s(\w+)[.-]([[:alnum:]\.]+)(?:\s?\/\s?|_|,\s|-)D([\w\.]+)\s?,?\s\w+(?:\s\d{1,2},)?\s?(\d{2,4})/o,
           /^([A-Z\/]+)#{STD}\s(\w+)[.-]([\w.-]+)[\/\s]D([\w.]*)(?:-|,\s?\w+\s|\s\w+:|,\s)(\d{4})/o,
           /^([\w\/]+)(?:\sActive)?#{APPROV}(?:\sDraft)?#{STD}\s(\w+)[.-]([[:alnum:]\.]+)\sDraft\s([\w\.]+),\s\w+\s(\d{4})/o
        # "#{$1} #{$2}-#{sp $3}/D#{$4}.#{yn $5}"
        PubId.new(publisher: $1, number: $2, part: sp($3), draft: $4, year: $5).to_s

      # publisher, approval, number, draft, year
      when /^(\w+)#{APPROVAL}(?:\sDraft)?#{STD}\s([[:alnum:]]+)\s?[\/_]\s?D([\w\.]+),?\s\w+\s(\d{2,4})/o
        # "#{$1}#{$2} #{$3}/D#{$4}.#{yn $5}"
        PubId.new(publisher: $1, approval: $2, number: $3, draft: $4, year: $5).to_s
      when /^(\w+)\s(\w+)\/D([\d.]+),\s\w+[\s_](\d{4})(?:\s-\s\(?|_)?#{APPROVAL}/o
        # "#{$1} #{$5} #{$2}/D#{$3}.#{$4}"
        PubId.new(publisher: $1, number: $2, draft: $3, year: $4, approval: $5).to_s

      # publisher, number, part, rev, draft
      when /^(\w+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)\.([\w.]+)[-\s\/]?REV-?(\w+)\/D([\d.]+)/o
        # "#{$1} #{$2}-#{sp $3}/REV-#{$4}/D#{$5}"
        PubId.new(publisher: $1, number: $2, part: sp($3), rev: $4, draft: $5).to_s
      when /^(\w+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)\.([\w.]+)-REV\/D([\d.]+)/o
        # "#{$1} #{$2}-#{sp $3}/REV/D#{$4}"
        PubId.new(publisher: $1, number: $2, part: sp($3), rev: "", draft: $4).to_s

      # publisher, number, part, rev, year
      when /^(\w+)#{APPROV}(?:\sDraft)?\sStd\s(\w+)\.(\d+)\/rev(\d+),\s\w+\s(\d+)/o
        # "#{$1} #{$2}-#{sp $3}/REV-#{$4}.#{$5}}"
        PubId.new(publisher: $1, number: $2, part: sp($3), rev: $4, year: $5).to_s

      # publisher, stage, number, draft, year
      when /^([\w\/]+)\s(#{STAGES})\s([[:alnum:]]+)[\/_]D([\w.]+),(?:\s\w+)?\s(\d{4})/o
        # "#{$1} #{$2} #{$2}/D#{$4}.#{$5}"
        PubId.new(publisher: $1, stage: $2, number: $3, draft: $4, year: $5).to_s

      # publisher, stage, number, part, year, month
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)[.-](\d+)[\/_-](#{STAGES}),?\s(\w+)\s(\d{4})/o,
           /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)[.-]([\w-]+)[\/_](#{STAGES}),?\s(\w+)\s(\d{4})/o
        # "#{$1} #{$4} #{$2}-#{sp $3}.#{$6}-#{mn $5}"
        PubId.new(publisher: $1, number: $2, part: sp($3), stage: $4, year: $6, month: mn($5)).to_s
      when /^([A-Z\/]+)\s(#{STAGES})\s(\w+)-(\w+),\s(\w+)\s(\d{4})/o
        # "#{$1} #{$2} #{$3}-#{sp $4}.#{$6}-#{mn $5}"
        PubId.new(publisher: $1, number: $3, part: sp($4), stage: $2, year: $6, month: mn($5)).to_s

      # publisher, stage, number, part, year
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)[.-](\d+)[\/_-](#{STAGES}),?\s\w+\s(\d{4})/o,
           /^([A-Z\/]+)\s(\w+)-(\d+)[\/-](#{STAGES})(?:_|,\s|-)\w+\s?(\d{4})/o,
           /^([A-Z\/]+)\s(\w+)-(\d+)[\/-](#{STAGES})-(\d{4})/o
        # "#{$1} #{$4} #{$2}-#{sp $3}.#{$5}"
        PubId.new(publisher: $1, number: $2, part: sp($3), stage: $4, year: $5).to_s
      when /^([A-Z\/]+)\s(#{STAGES})\s(\w+)-([\w-]+),\s(\d{4})/o
        # "#{$1} #{$2} #{$3}-#{sp $4}.#{$5}"
        PubId.new(publisher: $1, number: $3, part: sp($4), stage: $2, year: $5).to_s

      # publisher, stage, number, year, month
      when /^([A-Z\/]+)\s(#{STAGES})\s(\w+)(?:\s\g<2>)?,\s(\w+)\s(\d{4})/o
        # "#{$1} #{$2} #{$3}.#{$5}-#{mn $4}"
        PubId.new(publisher: $1, number: $3, stage: $2, year: $5, month: mn($4)).to_s

      # publisher, stage, number, year
      when /^([A-Z\/]+)\s(#{STAGES})\s(\w+)(?:,\s\w+\s|:)(\d{4})/o
        # "#{$1} #{$2} #{$3}.#{$4}"
        PubId.new(publisher: $1, number: $3, stage: $2, year: $4).to_s
      when /^([A-Z\/]+)\s(\w+)\/(#{STAGES})-(\d{4})/o
        # "#{$1} #{$3} #{$2}.#{$4}"
        PubId.new(publisher: $1, number: $2, stage: $3, year: $4).to_s

      # publisher, stage, number, part
      when /^([A-Z\/]+)\s(\w+)-([\w-]+)\s(#{STAGES})/o
        # "#{$1} #{$4} #{$2}-#{$3}"
        PubId.new(publisher: $1, number: $2, part: $3, stage: $4).to_s
      when /^([A-Z\/]+)\s(\w+)-(#{STAGES})-(\w+)/o
        # "#{$1} #{$3} #{$2}-#{$4}"
        PubId.new(publisher: $1, number: $2, part: $4, stage: $3).to_s

      # publisher, number, corrigendum, year
      when /^(\w+)#{STD}\s(\w+)-\d{4}\/Cor\s?(\d)-(\d{4})/o
        # "#{$1} #{$2}/Cor#{$3}.#{$4}"
        PubId.new(publisher: $1, number: $2, corrigendum: $3, year: $4).to_s

      # publisher, number, rev, draft
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)-REV\/D([\d.]+)/o
        # "#{$1} #{$2}/REV/D#{$3}"
        PubId.new(publisher: $1, number: $2, rev: "", draft: $3).to_s

      # publisher, number, part, year, month
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)-([\w-]+),\s(\w+)\s?(\d{4})/o,
           /^(\w+)\sStd\s(\w+)\.(\w+)-\d{4}\/INT,?\s(\w+)\.?\s(\d{4})/
        # "#{$1} #{$2}-#{$3}.#{$5}-#{mn $4}"
        PubId.new(publisher: $1, number: $2, part: sp($3), year: $5, month: mn($4)).to_s

      # publisher, number, part, amendment, year
      when /^(\w+)\sStd\s(\w+)-(\w+)-(\d{4})\/Amd(\d)/o
        # "#{$1} #{$2}-#{$3}/Amd#{$5}.#{$4}"
        PubId.new(publisher: $1, number: $2, part: $3, amd: $5, year: $4).to_s

      # publisher, number, part, year
      when /^([A-Z\/]+)\s(\w+)-(\d{1,3}),\s\w+\s(\d{4})/,
           /^([A-Z\/]+)#{STD}\s(\w+)[.-](?!(?:19|20)\d{2}\D)([\w.]+)(?:,\s\w+\s|-|,\s)(\d{4})/o,
           /^(\w+)#{STD}\sNo(?:\.?\s|\.)(\w+)\.(\d+)\s?-(?:\w+\s)?(\d{4})/o
        # "#{$1} #{$2}-#{$3}.#{$4}"
        PubId.new(publisher: $1, number: $2, part: sp($3), year: $4).to_s

      # publisher, number, edition, year
      when /^([A-Z\/]+)\s(\w+)\s(\w+)\sEdition,\s\w+\s(\d+)/ # "#{$1} #{$2}/E#{en $3}.#{$4}"
        PubId.new(publisher: $1, number: $2, edition: en($3), year: $4).to_s

      # publisher, number, part, conformance, draft
      when /^(\w+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)\.([[:alnum:].]+)[\/-]Conformance(\d+)[\/_]D([\w\.]+)/o
        # "#{$1} #{$2}-#{sp $3}/#{$4}/D#{$5}"
        PubId.new(publisher: $1, number: $2, part: "#{sp($3)}-#{$4}", draft: $5).to_s

      # publisher, number, part, conformance, year
      when /^(\w+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)\.([[:alnum:].]+)\s?\/\s?Conformance(\d+)-(\d{4})/o
        # "#{$1} #{$2}-#{sp $3}/#{$4}.#{$5}"
        PubId.new(publisher: $1, number: $2, part: "#{sp($3)}-#{$4}", year: $5).to_s

      # publisher, number, part, draft
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)\.([[:alnum:].]+)[^\/]*\/D([[:alnum:]\.]+)/o,
           /^([A-Z\/]+)\s(\w+)[.-]([[:alnum:]-]+)[\s_]D([\d.]+)/,
           /^([A-Z\/]+)\s(\w+)-(\w+)\/D([\w.]+)/
        # "#{$1} #{$2}-#{sp $3}/D#{$4}"
        PubId.new(publisher: $1, number: $2, part: sp($3), draft: $4).to_s

      # number, part, draft, year
      when /^(\w+)[.-]([[:alnum:].-]+)(?:\/|,\s|_)D([\d.]+),?\s\w+,?\s(\d{4})/
        # "IEEE #{$1}-#{sp $2}/D#{$3}.#{$4}"
        PubId.new(publisher: "IEEE", number: $1, part: sp($2), draft: $3, year: $4).to_s

      # publisher, number, draft, year, month
      when /^([A-Z\/]+)\s(\w+)\/D([\d.]+),\s(\w+)\s(\d{4})/ # "#{$1} #{$2}/#{$3}.#{$5}-#{mn $4}"
        PubId.new(publisher: $1, number: $2, draft: $3, year: $5, month: mn($4)).to_s

      # publisher, number, draft, year
      when /^([\w\/]+)(?:\sActive)?#{APPROV}(?:\sDraft)?#{STD}\s([[:alnum:]]+)\s?[\/_]\s?D([\w\.-]+),?\s(?:\w+\s)?(\d{2,4})/o,
           /^([\w\/]+)(?:\sActive)?#{APPROV}(?:\sDraft)?#{STD}\s([[:alnum:]]+)\/?D?([\d\.]+),?\s\w+\s(\d{4})/o,
           /^(\w+)\s(\w+)\/Draft\s([\d.]+),\s\w+\s(\d{4})/
        # "#{$1} #{$2}/D#{dn $3}.#{yn $4}"
        PubId.new(publisher: $1, number: $2, draft: dn($3), year: yn($4)).to_s
      when /^(\w+)\sStd\s(\w+)-(\d{4})\sDraft\s([\d.]+)/ # "#{$1} #{$2}/D#{$4}.#{$3}"
        PubId.new(publisher: $1, number: $2, draft: $4, year: $3).to_s

      # publisher, approval, number, draft
      when /^(\w+)#{APPROVAL}(?:\sDraft)?#{STD}\s([[:alnum:]]+)[\/_]D([\w.]+)/o
        # "#{$1}#{$2} #{$3}/D#{$4}"
        PubId.new(publisher: $1, approval: $2, number: $3, draft: $4).to_s

      # number, draft, year
      when /^(\w+)\/D([\w.+]+),?\s\w+,?\s(\d{4})/
        # "IEEE #{$1}/D#{$2}.#{$3}"
        PubId.new(publisher: "IEEE", number: $1, draft: $2, year: $3).to_s

      # number, rev, draft
      when /^(\w+)-REV\/D([\d.]+)/o
        # "IEEE #{$1}/REV/D#{$2}"
        PubId.new(publisher: "IEEE", number: $1, rev: "", draft: $2).to_s

      # publisher, number, draft
      when /^([\w\/]+)#{APPROV}(?:\sDraft)?#{STD}\s([[:alnum:]]+)[\/_]D([\w.]+)/o
        # "#{$1} #{$2}/D#{$3}"
        PubId.new(publisher: $1, number: $2, draft: $3).to_s

      # publisher, number, year, month
      when /^(\w+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)(?:-\d{4})?,\s(\w+)\s(\d{4})/o
        # "#{$1} #{$2}.#{$4}-#{mn $3}"
        PubId.new(publisher: $1, number: $2, year: $4, month: mn($3)).to_s

      # publisher, number, year, redline
      when /^([A-Z\/]+)#{STD}\s(\w+)-(\d{4})\s-\s(Redline)/o
        PubId.new(publisher: $1, number: $2, year: $3, redline: true).to_s

      # publisher, number, year
      when /^(\w+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)(?:-|,\s(?:\w+\s)?)(\d{2,4})/o,
           /^(\w+)#{APPROV}(?:\sDraft)?\sStd\s(\w+)\/\w+\s(\d{4})/o,
           /^([\w\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)\/FCD-\w+(\d{4})/o,
           /^(\w+)#{STD}\sNo(?:\.?\s|\.)(\w+)\s?(?:-|,\s)(?:\w+\s)?(\d{4})/o,
           /^(\w+)\sStd\s(\w+)\/INT-(\d{4})/
        # "#{$1} #{$2}.#{yn $3}"
        PubId.new(publisher: $1, number: $2, year: yn($3)).to_s

      # publisher, number, part
      when /^(\w+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)\.([\d.]+)/o # "#{$1} #{$2}-#{sp $3}"
        PubId.new(publisher: $1, number: $2, part: sp($3)).to_s

      # number, part, draft
      when /^(\w+)\.([\w.]+)\/D([\w.]+)/
        PubId.new(publisher: "IEEE", number: $1, part: $2, draft: $3).to_s

      # number, part, year
      when /^(\d{2})\sIRE\s(\w+)[\s.](\w+)/ # "IRE #{$2}-#{$3}.#{yn $1}"
        PubId.new(publisher: "IRE", number: $2, part: $3, year: yn($1)).to_s

      # publisher, number
      when /^(\w+)#{APPROV}(?:\sDraft)?#{STD}(?:\sNo\.?)?\s(\w+)/o # "#{$1} #{$2}"
        PubId.new(publisher: $1, number: $2).to_s

      else
        warn "Failed to parse normtitle #{normtitle}"
        nil # normtitle
      end
    rescue ArgumentError => e
      e
    end

    # replace subpart's delimiter
    #
    # @param parts [Strong]
    #
    # @return [String]
    def sp(parts)
      parts.gsub ".", "-"
    end

    #
    # Convert 2 digits year to 4 digits
    #
    # @param [String] year
    #
    # @return [String, nil] nil if string's length isn't 2 or 4
    #
    def yn(year)
      return year if year.size == 4

      case year.to_i
      when 0..25 then "20#{year}"
      when 26..99 then "19#{year}"
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
      n = Date::ABBR_MONTHNAMES.index(month) || Date::MONTHNAMES.index(month)
      return month unless n

      n.to_s.rjust 2, "0"
    end

    #
    # Convert edition name to number
    #
    # @param [Strin] edition
    #
    # @return [String]
    #
    def en(edition)
      case edition
      when "First" then 1
      else edition
      end
    end

    def dn(draftnum)
      draftnum.gsub "-", "."
    end

    extend RawbibIdParser
  end
end
