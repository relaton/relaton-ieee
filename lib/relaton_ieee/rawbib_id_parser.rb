module RelatonIeee
  module RawbibIdParser
    STAGES = "DIS|PSI|FCD|FDIS|CD|CD2|CD3|Pub2".freeze
    APPROVAL = '\sUnapproved|\sApproved'.freeze
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
      when "IEEE Std P1073.1.3.4/D3.0" then "IEEE P11073-00101"
      when "P1073.1.3.4/D3.0" then "IEEE P1073-1-3-4/D3.0"
      when "IEEE P1073.2.1.1/D08" then "ISO/IEEE P1073-2-1-1/D08"
      when "IEEE P802.1Qbu/03.0, July 2015" then "IEEE P802.1Qbu/D3.0.2015"
      when "IEEE P11073-10422/04, November 2015" then "IEEE P11073-10422/D04.2015"
      when "IEEE P802.11aqTM/013.0 October 2017" then "IEEE P802-11aqTM/D13.0.2017"
      when "IEEE P844.3/C22.2 293.3/D0, August 2018" then "IEEE P844.3/C22.2 293.3/D0.2018"
      when "IEEE P844.3/C22.2 293.3/D1, November 2018" then "IEEE P844.3/C22.2 293.3/D1.2018"
      when "AIEE No 431 (105) -1958" then "AIEE 431.1958"
      when "IEEE 1076-CONC-I99O" then "IEEE 1076.199O"
      when "IEEE Std 960-1993, IEEE Std 1177-1993" then "IEEE 960/1177.1993"
      when "IEEE P802.11ajD8.0, August 2017" then "IEEE P802-11aj/D8.0.2017"
      when "IEEE P802.11ajD9.0, November 2017" then "IEEE P802-11aj/D9.0.2017"

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
      when "IEEE Std P1641.1/D3, July 2006" then "IEEE Std P1641.1/D3, July 2006"
      when "IEEE P802.1AR-Rev/D2.2, September 2017 (Draft Revision of IEEE Std 802.1AR\u20132009)" then nil
      when "IEEE Std 108-1955; AIEE No.450-April 1955" then nil
      when "IEEE Std 85-1973 (Revision of IEEE Std 85-1965)" then nil
      when "IEEE Std 1003.1/2003.l/lNT, March 1994 Edition" then nil

      # publisher1, number1, part1, publisher2, number2, part2, draft, year
      when /^(\w+)\s(\w+)[-.](\d+)\/(\w+)\s(\w+)[-.](\d+)_(D[\d\.]+),\s\w+\s(\d{4})/
        "#{$1} #{$2}-#{$3}/#{$4} #{$5}-#{$6}/#{$7}.#{$8}"

      # publisher, approval, number, part, corrigendum, draft, year
      when /^(\w+)(#{APPROVAL})(?:\sDraft)?\sStd\s(\w+)\.(\d+)-\d{4}[^\/]*\/Cor\s?(\d)\/(D[\d\.]+),\s(?:\w+\s)?(\d{4})/o
        "#{$1}#{$2} #{$3}-#{sp $4}/Cor#{$5}/#{$6}.#{$7}"

      # publisher, number, part, corrigendum, draft, year, month
      when /^(\w+)(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s(\w+)\.(\d+)-\d{4}\/Cor\s?(\d(?:-\d+x)?)\/(D[\d\.]+),\s(\w+)\s(\d{4})/o
        "#{$1} #{$2}-#{$3}/Cor#{$4}/#{$5}.#{$7}-#{mn $6}"

      # publidsher1, number1, year1 publisher2, number2, draft, year2
      when /^(\w+)\s(\w+)-(\d{4})\/([A-Z]+)\s([[:alnum:]]+)_(D[\w.]+),\s(\d{4})/
        "#{$1} #{$2}.#{$3}/#{$4} #{$5}/#{$6}.#{$7}"

      # publidsher1, number1, publisher2, number2, draft, year
      when /^(\w+)(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s(\w+)\/([A-Z]+)\s([[:alnum:]]+)_(D[\d\.]+),\s\w+\s(\d{4})/o,
           /^(\w+)\s(\w+)\sand\s([A-Z]+)(?:\sGuideline)?\s([[:alnum:]]+)\/(D[\d\.]+),\s\w+\s(\d{4})/o
        "#{$1} #{$2}/#{$3} #{$4}/#{$5}.#{$6}"

      # publidsher1, number1, part, publisher2, number2, year
      when /^([A-Z\/]+)\s(\w+)\.(\d+)_(\w+)\s(\w+),\s(\d{4})/ then "#{$1} #{$2}-#{$3}/#{$4} #{$5}.#{$6}"

      # publisher, number1, part1, number2, part2, draft
      when /^([A-Z\/]+)\s(\w+)[.-](\d+)\/(\w+)\.(\d+)[\/_](D[\d.]+)/ then "#{$1} #{$2}-#{$3}/#{$4}-#{$5}/#{$6}"

      # publidsher, number1, part1, number2, part2, year
      when /^(\w+)\sStd\s(\w+)\.(\w+)\/(\w+)\.(\w+)\/INT\s\w+\s(\d{4})/
        "#{$1} #{$2}-#{$3}/#{$4}-#{$5}.#{$6}"

      # publisher, number, part, corrigendum, draft, year
      when /^(\w+)(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s(\w+)[.-]([\d-]+)\/Cor\s?(\d)[\/_](D[\d\.]+),\s(?:\w+\s)?(\d{4})/o,
           /^(\w+)\s(\w+)[.-](\d+)-\d{4}\/Cor\s?(\d)(?:-|,\s|\/)(D[\d.]+),?\s\w+\s(\d{4})/,
           /^(\w+)\s(\w+)\.([[:alnum:].]+)[-_]Cor[\s-]?(\d)\/(D[\d.]+),?\s\w+\s(\d{4})/
        "#{$1} #{$2}-#{sp $3}/Cor#{$4}/#{$5}.#{$6}"
      when /^(\w+)\s(\w+)\.(\d+)-\d{4}\/Cor(\d)-(\d{4})\/(D[\d.]+)/ then "#{$1} #{$2}-#{$3}/Cor#{$4}/#{$6}.#{$5}"

      # publisher, status, number, part, draft, year, month
      when /^(\w+)(\sActive)(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s(\w+)[\.-]([[:alnum:]\.]+)\s?[\/_](D[\w\.]+),?\s(\w+)(?:\s\d{1,2},)?\s?(\d{2,4})/o
        "#{$1}#{$2} #{$3}-#{sp $4}/#{$5}.#{yn $7}-#{mn $6}"

      # publisher, approval, number, part, draft, year, month
      when /^(\w+)(?:\sActive)?(#{APPROVAL})(?:\sDraft)?#{STD}\s(\w+)[\.-]([[:alnum:]\.]+)\s?[\/_](D[\w\.-]+),?\s(\w+)(?:\s\d{1,2},)?\s?(\d{2,4})/
        "#{$1}#{$2} #{$3}-#{sp $4}/#{$5}.#{yn $7}-#{mn $6}"

      # publisher, approval, number, part, draft, year
      when /^(\w+)(#{APPROVAL})(?:\sDraft)?#{STD}\s(\w+)[\.-]([\w\.]+)\s?[\/_\s](D[\w\.]+),?\s\w+\s?(\d{4})/o
        "#{$1}#{$2} #{$3}-#{sp $4}/#{$5}.#{$6}"
      when /^(\w+)\s(\w+)\.([\w.]+)\/(D[\d.]+),?\s\w+[\s_](\d{4})(?:\s-\s\(|_|\s\()?(Approved)/
        "#{$1} #{$6} #{$2}-#{sp $3}/#{$4}.#{$5}"

      # number, part, corrigendum, draft, year
      when /^(\w+)\.([\w.]+)-\d{4}\/Cor\s?(\d)\/(D[\w.]+),\s\w+\s(\d{4})/
        "IEEE #{$1}-#{sp $2}/Cor#{$3}/#{$4}.#{$5}"

      # publisher, approval, number, part, draft
      when /^(\w+)\s(\w+)\.(\d+)\/(D[\d\.]+)\s\([^\)]+\)\s-(#{APPROVAL})/o
        "#{$1} #{$5} #{$2}-#{$3}/#{$4}"

      # publisher, number, part1, rev, draft, part2
      when /^(\w+)#{STD}\s(\w+)\.([\d.]+)REV([a-z]+)_(D[\w.]+)\sPart\s(\d)/
        "#{$1} #{$2}-#{sp $3}/REV-#{$4}/#{$5}/Part-#{$6}"

      # publisher, number, part, draft, year, month
      when /^([A-Z\/]+)#{STD}\s(\w+)[.-]([[:alnum:].]+)[\/\s_](D[\d.]+)(?:,\s|_)(\w+)\s?(\d{4})/
        "#{$1} #{$2}-#{sp $3}/#{$4}.#{$6}-#{mn $5}"

      # publisher, stage, number, part, draft, year
      when /^([\w\/]+)\s(#{STAGES})\s(\w+)-([[:alnum:]]+)[\/_\s](D[\d\.]+),\s\w+\s(\d{4})/o
        "#{$1} #{$2} #{$3}-#{sp $4}/#{$5}.#{$6}"

      # publisher, number, part, rev, draft, year, month
      when /^(\w+)\s(\w+)\.([\w.]+)-Rev\/(D[\w.]+),\s(\w+)\s(\d{4})/
        "#{$1} #{$2}-#{sp $3}/REV/#{$4}.#{$6}-#{mn $5}"

      # publisher, number, part, rev, draft, year
      when /^(\w+)\s(\w+)\.([\d.]+)Rev(\w+)-(D[\w.]+),\s\w+\s(\d{4})/
        "#{$1} #{$2}-#{sp $3}/REV-#{$4}/#{$5}.#{$6}"

      # publisher, number, corrigendum, draft, year
      when /^(\w+)(?:\sUnapproved|\sApproved)?(?:\sDraft)?\sStd\s(\w+)(?:-\d{4})?[\/_]Cor\s?(\d)\/(D[\d\.]+),\s\w+\s(\d{4})/
        "#{$1} #{$2}/Cor#{$3}/#{$4}.#{$5}"

      # publisher, number, part, rev, corrigendum, draft
      when /^(\w+)\s(\w+)\.(\w+)-\d{4}-Rev\/Cor(\d)\/(D[\d.]+)/
        "#{$1} #{$2}-#{$3}/REV/Cor#{$4}/#{$5}"

      # publisher, number, part, corrigendum, draft
      when /^(\w+)(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s(\w+)\.([\w\.]+)\/[Cc]or\s?(\d)\/(D[\w\.]+)/o,
           /^(\w+)(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s(\w+)\.(\w+)-\d{4}\/Cor\s?(\d)[\/_](D[\d\.]+)/o
        "#{$1} #{$2}-#{sp $3}/Cor#{$4}/#{$5}"

      # publisher, number, part, corrigendum, year
      when /^(\w+)#{STD}\s(\w+)\.([\w.]+)-\d{4}\/Cor\s?(\d)-(\d{4})/
        "#{$1} #{$2}-#{$3}/Cor#{$4}.#{$5}"

      # publisher, number, part, draft, year
      when /^([\w\/]+)(?:\sActive)?(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s(\w+)[\.-]([[:alnum:]\.]+)(?:\s?\/\s?|_|,\s|-)(D[\w\.]+)\s?,?\s\w+(?:\s\d{1,2},)?\s?(\d{2,4})/o,
           /^([A-Z\/]+)#{STD}\s(\w+)[.-]([\w.-]+)[\/\s](D[\w.]*)(?:-|,\s?\w+\s|\s\w+:)(\d{4})/
        "#{$1} #{$2}-#{sp $3}/#{$4}.#{yn $5}"
      when /^([\w\/]+)(?:\sActive)?(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s(\w+)[\.-]([[:alnum:]\.]+)\sDraft\s([\w\.]+),\s\w+\s(\d{4})/o
        "#{$1} #{$2}-#{sp $3}/D#{$4}.#{yn $5}"

      # publisher, approval, number, draft, year
      when /^(\w+)(#{APPROVAL})(?:\sDraft)?#{STD}\s([[:alnum:]]+)\s?[\/_]\s?(D[\w\.]+),?\s\w+\s(\d{2,4})/o
        "#{$1}#{$2} #{$3}/#{$4}.#{yn $5}"
      when /^(\w+)\s(\w+)\/(D[\d.]+),\s\w+[\s_](\d{4})(?:\s-\s\(?|_)?(Approved)/
        "#{$1} #{$5} #{$2}/#{$3}.#{$4}"

      # publisher, number, part, rev, draft
      when /^(\w+)(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s(\w+)\.([\w.]+)[-\s\/]?REV-?(\w+)\/(D[\d.]+)/o
        "#{$1} #{$2}-#{sp $3}/REV-#{$4}/#{$5}"
      when /^(\w+)(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s(\w+)\.([\w.]+)-REV\/(D[\d.]+)/o
        "#{$1} #{$2}-#{sp $3}/REV/#{$4}"
      when /^(\w+)(?:#{APPROVAL})?(?:\sDraft)?\sStd\s(\w+)\.(\d+)\/rev(\d+),\s\w+\s(\d+)/o
        "#{$1} #{$2}-#{sp $3}/REV-#{$4}-#{$5}}"

      # publisher, stage, number, draft, year
      when /^([\w\/]+)\s(#{STAGES})\s(\w+)[\/_](D[\d\.]+),\s\w+\s(\d{4})/o
        "#{$1} #{$2} #{$2}/#{$4}.#{$5}"

      # publisher, stage, number, part, year, month
      when /^([A-Z\/]+)(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s(\w+)[.-](\d+)[\/_-](#{STAGES}),?\s(\w+)\s(\d{4})/o
        "#{$1} #{$4} #{$2}-#{sp $3}.#{$6}-#{mn $5}"

      # publisher, stage, number, part, year
      when /^([A-Z\/]+)(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s(\w+)[.-](\d+)[\/_-](#{STAGES}),?\s\w+\s(\d{4})/o,
           /^([A-Z\/]+)\s(\w+)-(\d+)[\/-](#{STAGES})(?:_|,\s|-)\w+\s?(\d{4})/o,
           /^([A-Z\/]+)\s(\w+)-(\d+)[\/-](#{STAGES})-(\d{4})/o
        "#{$1} #{$4} #{$2}-#{sp $3}.#{$5}"

      # publisher, stage, number, year
      when /^([A-Z\/]+)\s(#{STAGES})\s(\w+)(?:,\s\w+\s|:)(\d{4})/
        "#{$1} #{$2} #{$3}.#{$4}"
      when /^([A-Z\/]+)\s(\w+)\/(#{STAGES})-(\d{4})/
        "#{$1} #{$3} #{$2}.#{$4}"

      # publisher, stage, number, part
      when /^([A-Z\/]+)\s(\w+)-([\w-]+)\s(#{STAGES})/
        "#{$1} #{$4} #{$2}-#{$3}"

      # publisher, number, corrigendum, year
      when /^(\w+)#{STD}\s(\w+)-\d{4}\/Cor\s?(\d)-(\d{4})/
        "#{$1} #{$2}/Cor#{$3}.#{$4}"

      # publisher, number, rev, draft
      when /^(\w+)(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s(\w+)-REV\/(D[\d\.]+)/o
        "#{$1} #{$2}/REV/#{$3}"

      # publisher, number, part, year, month
      when /^(\w+)(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s(\w+)-(\d),\s(\w+)\s?(\d{4})/o,
           /^(\w+)\sStd\s(\w+)\.(\w+)-\d{4}\/INT,?\s(\w+)\.?\s(\d{4})/
        "#{$1} #{$2}-#{$3}.#{$5}-#{mn $4}"

      # publisher, number, part, amendment, year
      when /^(\w+)\sStd\s(\w+)-(\w+)-(\d{4})\/Amd(\d)/o
        "#{$1} #{$2}-#{$3}/Amd#{$5}.#{$4}"

      # publisher, number, part, year
      when /^([A-Z\/]+)\s(\w+)-(\d{1,3}),\s\w+\s(\d{4})/,
           /^(\w+)#{STD}\s(\w+)[.-](?!(?:19|20)\d{2}\D)([\w.]+)(?:,\s\w+\s|-|,\s)(\d{4})/,
           /^(\w+)#{STD}\sNo(?:\.?\s|\.)(\w+)\.(\d+)\s?-(?:\w+\s)?(\d{4})/
        "#{$1} #{$2}-#{$3}.#{$4}"

      when /^([A-Z\/]+)\s(\w+)\s(\w+)\sEdition,\s\w+\s(\d+)/ then "#{$1} #{$2}/E#{en $3}.#{$4}"

      # publisher, number, part, conformance, draft
      when /^(\w+)(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s(\w+)\.([[:alnum:]\.]+)[\/-](Conformance\d+)[\/_](D[\w\.]+)/o
        "#{$1} #{$2}-#{sp $3}/#{$4}/#{$5}"

      # publisher, number, part, conformance, year
      when /^(\w+)(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s(\w+)\.([[:alnum:]\.]+)\s?\/\s?(Conformance\d+)-(\d{4})/o
        "#{$1} #{$2}-#{sp $3}/#{$4}.#{$5}"

      # publisher, number, part, draft
      when /^(\w+)(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s(\w+)\.([[:alnum:]\.]+)[^\/]*\/(D[[:alnum:]\.]+)/o,
           /^(\w+)\s(\w+)[\.-]([\d\/]+)[\s_](D[\d.]+)/
        "#{$1} #{$2}-#{sp $3}/#{$4}"

      # number, part, draft, year
      when /^(\w+)[.-]([\w.-]+)(?:\/|,\s)(D[\d.]+),?\s\w+,?\s(\d{4})/ then "IEEE #{$1}-#{sp $2}/#{$3}.#{$4}"

      # publisher, number, draft, year, month
      when /^([A-Z\/]+)\s(\w+)\/(D[\d.]+),\s(\w+)\s(\d{4})/ then "#{$1} #{$2}/#{$3}.#{$5}-#{mn $4}"

      # publisher, number, draft, year
      when /^([\w\/]+)(?:\sActive)?(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s([[:alnum:]]+)\s?[\/_]\s?(D[\w\.-]+),?\s(?:\w+\s)?(\d{2,4})/o
        "#{$1} #{$2}/#{dn $3}.#{yn $4}"
      when /^([\w\/]+)(?:\sActive)?(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s([[:alnum:]]+)\/?D?([\d\.]+),?\s\w+\s(\d{4})/o
        "#{$1} #{$2}/D#{$3}.#{yn $4}"
      when /^(\w+)\sStd\s(\w+)-(\d{4})\sDraft\s([\d.]+)/ then "#{$1} #{$2}/#{$4}.#{$3}"
      when /^(\w+)\s(\w+)\/Draft\s([\d.]+),\s\w+\s(\d{4})/ then "#{$1} #{$2}/D#{$3}.#{$4}"

      # publisher, approval, number, draft
      when /^(\w+)(#{APPROVAL})(?:\sDraft)?#{STD}\s([[:alnum:]]+)[\/_](D[\w\.]+)/o
        "#{$1}#{$2} #{$3}/#{$4}"

      # number, draft, year
      when /^(\w+)\/(D[\w\.+]+),?\s\w+,?\s(\d{4})/
        "IEEE #{$1}/#{$2}.#{$3}"

      # number, rev, draft
      when /^(\w+)-REV\/(D[\d\.]+)/o
        "IEEE #{$1}/REV/#{$2}"

      # publisher, number, draft
      when /^([\w\/]+)(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s([[:alnum:]]+)[\/_](D[\w\.]+)/o
        "#{$1} #{$2}/#{$3}"

      # publisher, number, year, month
      when /^(\w+)(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s(\w+)(?:-\d{4})?,\s(\w+)\s(\d{4})/o
        "#{$1} #{$2}.#{$4}-#{mn $3}"

      # publisher, number, year
      when /^(\w+)(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s(\w+)(?:-|,\s(?:\w+\s)?)(\d{2,4})/o,
           /^(\w+)(?:#{APPROVAL})?(?:\sDraft)?\sStd\s(\w+)\/\w+\s(\d{4})/o,
           /^([\w\/]+)(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s(\w+)\/FCD-\w+(\d{4})/o,
           /^(\w+)#{STD}\sNo(?:\.?\s|\.)(\w+)\s?(?:-|,\s)(?:\w+\s)?(\d{4})/,
           /^(\w+)\sStd\s(\w+)\/INT-(\d{4})/
        "#{$1} #{$2}.#{yn $3}"

      # publisher, number, part
      when /^(\w+)(?:#{APPROVAL})?(?:\sDraft)?#{STD}\s(\w+)\.([\d\.]+)/ then "#{$1} #{$2}-#{sp $3}"

      # number, part, year
      when /^(\d{2})\sIRE\s(\w+)[\s.](\w+)/ then "IRE #{$2}-#{$3}.#{yn $1}"

      # publisher, number
      when /^(\w+)(?:#{APPROVAL})?(?:\sDraft)?#{STD}(?:\sNo\.?)?\s(\w+)/ then "#{$1} #{$2}"

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
