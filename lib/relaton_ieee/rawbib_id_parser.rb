require "pubid-ieee"
require "relaton_ieee/pub_id"

module RelatonIeee
  module RawbibIdParser
    STAGES = 'DIS\d?|PSI|FCD|FDIS|CD\d?|Pub2|CDV|TS|SI'.freeze
    APPROVAL = '(?:\s(Unapproved|Approved))'.freeze
    APPROV = '(?:\s(?:Unapproved|Approved))?'.freeze
    STD = "(?:\s(?i)Std.?(?-i))?".freeze

    #
    # Parse normtitle
    #
    # @param [String] normtitle document element "normtitle"
    # @param [String] stdnumber document element "stdnumber"
    #
    # @return [RelatonIeee::PubId, nil]
    #
    def parse(normtitle, stdnumber) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      normtitle.sub!("IEEE Std P650/D9. Feb 2006", "IEEE Std P650/D9 Feb 2006")
      normtitle.sub!("ANSI/IEEE Std: 8-Bit Backplane Interface - STEbus,", "ANSI/IEEE Std 8-Bit")
      normtitle.sub!("IEEE Approved Draft Std P1234 / D12, Feb 2007", "IEEE Approved Draft Std P1234/D12 Feb 2007")
      normtitle.sub!("IEEE Approved Draft Std P277/D2 - Mar 2007", "IEEE Approved Draft Std P277/D2 Mar 2007")
      normtitle.sub!("IEEE Std P802.8/D.3.2", "IEEE Std P802.8/D3.2")
      normtitle.sub!("IEEE Std P802/D27/Mar", "IEEE Std P802/D27 Mar 1999")
      normtitle.sub!("IEEE Std P802.1w/D10/Mar", "IEEE Std P802.1w/D10 Mar 2001")
      normtitle.sub!("IEEE Std P762-2006(R2002)", "IEEE Std P762-2006")
      normtitle.sub!("IEEE Std P802.16.2-REVa/D8", "IEEE Std P802.16.2/D8")
      normtitle.sub!("IEEE P802.11e/D6.0, November 2003 (Draft Amendment to IEEE Std 802.11, 1999 Edition (Reaff 2003))", "IEEE P802.11e/D6.0 November 2003 (Amendment to IEEE Std 802.11, 1999 Edition)")
      normtitle.sub!("IEEE Std P802.16/REVd/D5", "IEEE Std P802.16-REVd/D5")
      normtitle.sub!("IEEE Std P930/D5-2004/May", "IEEE Std P930/D5 May 2004")
      normtitle.sub!("IEEE Std P802.15.1REVa/D5", "IEEE Std P802.15.1/D5")
      normtitle.sub!("IEEE Approved Std P277D1/Jan 2007", "IEEE Approved Std P277/D1 Jan 2007")
      normtitle.sub!("IEEE Approved Std P1512.4/rev44, Sep 2006", "IEEE Approved Std P1512.4-rev44, Sep 2006")
      normtitle.sub!("IEEE Unapproved Draft Std P15289, 06", "IEEE Unapproved Draft Std P15289 D06")
      normtitle.sub!("IEEE Std P802.11v/D10.0, Mar2010 (Amendment to IEEE Std 802.11-2007)", "IEEE Std P802.11v/D10.0 Mar 2010 (Amendment to IEEE Std 802.11-2007)")
      normtitle.sub!("IEEE Std P802.11z_D8.0_Apr2010 (Amendment to IEEE Std 802.11-2007)", "IEEE Std P802.11z_D8.0 Apr 2010 (Amendment to IEEE Std 802.11-2007)")
      normtitle.sub!("IEEE Std P802.3ba/D3.2, Mar2010, (Amendment to IEEE Std 802.3-2005)", "IEEE Std P802.3ba/D3.2 Mar 2010 (Amendment to IEEE Std 802.3-2005)")
      normtitle.sub!("ISO/IEC/IEEE P29148/FCD-June2010", "ISO/IEC/IEEE P29148/FCD, June 2010")
      normtitle.sub!("IEEE P802.1Qbe/D1.5_May 2010 (Draft Amendment to IEEE Std 802.1Q-2005)", "IEEE P802.1Qbe/D1.5 May 2010 (Amendment to IEEE Std 802.1Q-2005)")
      normtitle.sub!("IEEE Draft P802.11-REVmb/D3.0, March 2010 (Revision of IEEE Std 802.11-2007, as amended by IEEE Std 802.11k-2008, IEEE Std 802.11r-2008, IEEE Std 802.11y-2008, IEEE Std 802.11w-2009 and IEEE Std 802.11n-2009)", "IEEE Draft P802.11-REVmb/D3.0, March 2010 (Revision of IEEE Std 802.11-2007 and IEEE Std 802.11k-2008 and IEEE Std 802.11r-2008 and IEEE Std 802.11y-2008 and IEEE Std 802.11w-2009 and IEEE Std 802.11n-2009)")
      normtitle.sub!("IEEE P1036/D16_Rev3, June 2010", "IEEE P1036-Rev3/D16 June 2010")
      normtitle.sub!("IEEE P1584b/ D3, August 2010", "IEEE P1584b/D3 August 2010")
      normtitle.sub!("IEEE P1775/2.0.0 June 2010", "IEEE P1775/D2.0.0 June 2010")
      normtitle.sub!("IEEE Std PC57.106/D5 Dec", "IEEE Std PC57.106/D5 Dec 2005")
      normtitle.sub!("IEEE Std P802.16-Conformance04/D7", "IEEE Std P802.16")
      normtitle.sub!("IEEE Std P802.3ap/Draft 3.1", "IEEE Std P802.3ap/D3.1")
      normtitle.sub!("IEEE Std P1512.4/rev43", "IEEE Std P1512.4-rev43")
      normtitle.sub!("IEEE Std PC57.106/D6 Oct", "IEEE Std PC57.106/D6 Oct 2006")
      normtitle.sub!("IEEE Std P802.16/Conformance04/D6", "IEEE Std P802.16")
      normtitle.sub!("IEEE Std P1205-Corrigendum1, Dec 2006", "IEEE Std P1205/Cor 1, Dec 2006")
      normtitle.sub!("IEEE P802.1Qbb/D2.2 (DRAFT Amendment to IEEE Std 802.1Q -2005)", "IEEE P802.1Qbb/D2.2 (Amendment to IEEE Std 802.1Q-2005)")
      normtitle.sub!("P802.3bd/D2.2 August 2010. (Draft Amendment to IEEE Std 802.3-2008)", "P802.3bd/D2.2 August 2010 (Amendment to IEEE Std 802.3-2008)")
      normtitle.sub!("IEEE P802.11z/D13.0, August 2010. (Admendment to IEEE Std 802.11-2007)", "IEEE P802.11z/D13.0, August 2010 (Amendment to IEEE Std 802.11-2007)")
      normtitle.sub!("IEEE P802.1Qbb/D2.3, May 2010 (DRAFT Amendment to IEEE Std 802.1Q -2005)", "IEEE P802.1Qbb/D2.3, May 2010 (Amendment to IEEE Std 802.1Q-2005)")
      normtitle.sub!("IEEE PC62.62/D4.0 (BRC), July 2010", "IEEE PC62.62/D4.0 July 2010")
      normtitle.sub!("IEEE Draft P802.11-REVmb/D6.0, September 2010 (Revision of IEEE Std 802.11-2007, as amended by IEEE Std 802.11k-2008, IEEE Std 802.11r-2008, IEEE Std 802.11y-2008, IEEE Std 802.11w-2009 and IEEE Std 802.11n-2009)", "IEEE Draft P802.11-REVmb/D6.0, September 2010 (Revision of IEEE Std 802.11-2007 and IEEE Std 802.11k-2008 and IEEE Std 802.11r-2008 and IEEE Std 802.11y-2008 and IEEE Std 802.11w-2009 and IEEE Std 802.11n-2009)")
      normtitle.sub!("IEEE P1149.1/D2012.e27, September 2012", "IEEE P1149.1/D2012 September 2012")
      normtitle.sub!("P1857/D1+1, July 2012", "P1857/D1 July 2012")
      normtitle.sub!("IEEE P18/D3, Oct ober 2012", "IEEE P18/D3, October 2012")
      normtitle.sub!("IEEE P1149.1/D2012.e29, November 2012", "IEEE P1149.1/D2012 November 2012")
      normtitle.sub!("IEEE P1905.1/ D09, December 2012", "IEEE P1905.1/ D09, December 2012")
      normtitle.sub!("IEEE P1901.2_vD0.07.01, March 2013", "IEEE P1901.2_v/D0.07.01 March 2013")
      normtitle.sub!("IEEE P802.15.4REVi/D09, April 2011 (Revision of IEEE Std 802.15.4-2006)", "IEEE P802.15/D09 April 2011 (Revision of IEEE Std 802.15.4-2006)")
      normtitle.sub!("IEEE PC135.90 Draft 7.0 April 2013", "IEEE PC135.90/D7.0 April 2013")
      normtitle.sub!("IEEE P15026-4/Pub2-2012", "IEEE P15026-4 2012")
      normtitle.sub!("IEEE P463/D1+1, May 2013", "IEEE P463/D1 May 2013")
      normtitle.sub!("IEEE P692/D4d, 26 June 2013", "IEEE P692/D4d, June 2013")
      normtitle.sub!("IEEE P802.20a Draft 2.1, October 2010", "IEEE P802.20a/D2.1, October 2010")
      normtitle.sub!("IEEE Draft P802.3bf/D2.1, September 2010 (Draft Amendment to IEEE Std 802.3-2008)", "IEEE Draft Std P802.3bf/D2.1, September 2010 (Amendment to IEEE Std 802.3-2008)")
      normtitle.sub!("IEEE P802.1Qbe/D1.6_August 2010 (Draft Amendment to IEEE Std 802.1Q-2005)", "IEEE P802.1Qbe/D1.6 August 2010 (Amendment to IEEE Std 802.1Q-2005)")
      normtitle.sub!("IEEE P802.15.4REVi/D04, September, 2010", "IEEE P802.15.4/D04, September 2010")
      normtitle.sub!("IEEE Draft P802.11-REVmb/D7.0, February 2011 (Revision of IEEE Std 802.11-2007, as amended by IEEE Std 802.11k-2008, IEEE Std 802.11r-2008, IEEE Std 802.11y-2008, IEEE Std 802.11w-2009 and IEEE Std 802.11n-2009)", "IEEE Draft P802.11-REVmb/D7.0, February 2011 (Revision of IEEE Std 802.11-2007 and IEEE Std 802.11k-2008 and IEEE Std 802.11r-2008 and IEEE Std 802.11y-2008 and IEEE Std 802.11w-2009 and IEEE Std 802.11n-2009)")
      normtitle.sub!("IEEE P1310.Rev 3/D2, February 2011", "IEEE P1310-Rev3/D2, February 2011")
      normtitle.sub!("IEEE P1635 and ASHRAE Guideline 21/D8, December 2010", "IEEE P1635 21/D8, December 2010")
      normtitle.sub!("IEEE Draft P802.11-REVmb/D8.0, March 2011 (Revision of IEEE Std 802.11-2007, as amended by IEEE Std 802.11k-2008, IEEE Std 802.11r-2008, IEEE Std 802.11y-2008, IEEE Std 802.11w-2009 and IEEE Std 802.11n-2009)", "IEEE Draft P802.11-REVmb/D8.0, March 2011 (Revision of IEEE Std 802.11-2007 and IEEE Std 802.11k-2008 and IEEE Std 802.11r-2008 and IEEE Std 802.11y-2008 and IEEE Std 802.11w-2009 and IEEE Std 802.11n-2009)")
      normtitle.sub!("IEEE P802.1Qbe/D1.7_April 2011 (Draft Amendment to IEEE Std 802.1Q-2005)", "IEEE P802.1Qbe/D1.7 April 2011 (Amendment to IEEE Std 802.1Q-2005)")
      normtitle.sub!("IEEE P802.15.4REVi/D07, April 2011 (Revision of IEEE Std 802.15.4-2006)", "IEEE P802.15.4/D07, April 2011 (Revision of IEEE Std 802.15.4-2006)")
      normtitle.sub!("IEEE PC37.082_IEC 62271, 2010", "IEEE PC37.082, April 2010")
      normtitle.sub!("IEEE Std P1073.1.3.10/D3.0-1999", "IEEE Std P1073.1.3.10/D3.0 Jan 1999")
      normtitle.sub!("IEEE Std PC57.19.03/cor1/D2.2", "IEEE Std PC57.19.03/Cor1/D2.2")
      normtitle.sub!("IEEE PSI 10/D2, October 2010", "IEEE PSI10/D2, October 2010")
      normtitle.sub!("IEEE/ASTM PSI 10/D3, October 2010", "IEEE/ASTM PSI10/D3, October 2010")
      normtitle.sub!("IEEE PC57.16/D9, January - April 2011", "IEEE PC57.16/D9, April 2011")
      normtitle.sub!("Draft IEEE P802.15.4REVi/D09, April 2011 (Revision of IEEE Std 802.15.4-2006)", "IEEE P802.15.4/D09, April 2011 (Revision of IEEE Std 802.15.4-2006)")
      normtitle.sub!("IEEE Draft P802.11-REVmb/D9.0, May 2011 (Revision of IEEE Std 802.11-2007, as amended by IEEE Std 802.11k-2008, IEEE Std 802.11r-2008, IEEE Std 802.11y-2008, IEEE Std 802.11w-2009 and IEEE Std 802.11n-2009)", "IEEE Draft P802.11-REVmb/D9.0, May 2011 (Revision of IEEE Std 802.11-2007 and IEEE Std 802.11k-2008 and IEEE Std 802.11r-2008 and IEEE Std 802.11y-2008 and IEEE Std 802.11w-2009 and IEEE Std 802.11n-2009)")
      normtitle.sub!("IEEE PC57.16/D10, May - June 2011", "IEEE PC57.16/D10, June 2011")
      normtitle.sub!("ISO/IEC/IEEE P29148 First Edition, August 2011", "ISO/IEC/IEEE P29148 First edition 2011-08-01")
      normtitle.sub!("IEEE P802.15.4e/D6.0, July 2011 based on Draft IEEE P802.15.4 REVi/D09 (Revision of IEEE Std 802.15.4-2006)", "IEEE P802.15.4e/D6.0, July 2011 (Revision of IEEE Std 802.15.4-2006)")
      normtitle.sub!("IEEE PC37.13 - Amendment 1/D4, July 2011", "IEEE PC37.13/D4, July 2011/Amd1")
      normtitle.sub!("IEEE P802.11-REVmb/D10.0, August 2011 (Revision of IEEE Std 802.11-2007, as amended by IEEE Std 802.11k-2008, IEEE Std 802.11r-2008, IEEE Std 802.11y-2008, IEEE Std 802.11w-2009 and IEEE Std 802.11n-2009)", "IEEE P802.11-REVmb/D10.0, August 2011 (Revision of IEEE Std 802.11-2007 and IEEE Std 802.11k-2008 and IEEE Std 802.11r-2008 and IEEE Std 802.11y-2008 and IEEE Std 802.11w-2009 and IEEE Std 802.11n-2009)")
      normtitle.sub!("IEEE P802.1aq/D4.3, DRAFT Amendment to IEEE Std 802.1Q -2011, September 2011", "IEEE P802.1aq/D4.3, September 2011 (Amendment to IEEE Std 802.1Q -2011)")
      normtitle.sub!("IEEE P802.11-REVmb/D11, October 2011 (Revision of IEEE Std 802.11-2007, as amended by IEEEs 802.11k-2008, 802.11r-2008, 802.11y-2008, 802.11w-2009, 802.11n-2009, 802.11p-2010, 802.11z-2010, 802.11v-2011, 802.11u-2011, and 802.11s-2011)", "IEEE P802.11-REVmb/D11, October 2011 (Revision of IEEE Std 802.11-2007 and IEEE Std 802.11k-2008 and IEEE Std 802.11r-2008 and IEEE Std 802.11y-2008 and IEEE Std 802.11w-2009 and IEEE Std 802.11n-2009 and IEEE Std 802.11p-2010 and IEEE Std 802.11z-2010 and IEEE Std 802.11v-2011 and IEEE Std 802.11u-2011 and IEEE Std 802.11s-2011)")
      normtitle.sub!("IEEE P802.15.4e/D7.0, September 2011, based on IEEE P802.15.4-2011", "IEEE P802.15.4e/D7.0, September 2011")

      normtitle.sub!(/\.pdf|,\z|\.\z/, "")
      normtitle.sub!(/(?<=\()draft\s(?=.*\)\z)/i, "")
      normtitle.sub!(/\AIEEE(.*)\s\(Approved Draft\)\z/, 'IEEE Approved Draft Std\1')
      normtitle.sub!(/\AIEEE\sDraft\s(?!Std)/, "IEEE Draft Std")
      normtitle.sub!(/\(Draft\sAmendment/i, "(Amendment")
      normtitle.sub!(/\/(D\d+)\+(\d)/, '/\1.\2')
      normtitle.sub!("Std.", "Std")

      pubid = Pubid::Ieee::Identifier.parse normtitle
      return pubid if pubid

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
      when "IEEE Std P1073.1.3.4/D3.0" then PubId.new(publisher: "IEEE", number: "P11073", part: "00101") # "IEEE P11073-00101"
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
        PubId.new([{ publisher: "IEEE", number: "960" }, { number: "1177", year: "1993" }])
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
        PubId.new(publisher: "ANSI/IEEE", number: "21", year: "1976", month: "11")
      when "Unapproved Draft Std ISO/IEC FDIS 15288:2007(E) IEEE P15288/D3,"
        PubId.new(publisher: "ISO/IEC/IEEE", stage: "FDIS", number: "P15288", draft: "3", year: "2007")
      when "Draft National Electrical Safety Code, January 2016"
        PubId.new(publisher: "IEEE", number: "PC2", year: "2016", month: "01")
      when "ANSI/IEEE-ANS-7-4.3.2-1982" then PubId.new(publisher: "ANSI/IEEE/ANS", number: "7", part: "4-3-2", year: "1982")
      when "IEEE Unapproved Draft Std P802.1AB/REVD2.2, Dec 2007" # "IEEE P802.1AB/REV/D2.2.2007"
        PubId.new(publisher: "IEEE", number: "P802", part: "1AB", rev: "", draft: "2.2", year: "2007", month: "12")
      when "International Standard ISO/IEC 8802-9: 1996(E) ANSI/IEEE Std 802.9, 1996 Edition"
        PubId.new(publisher: "ISO/IEC/IEEE", number: "802", part: "9", year: "1996")
      when "ISO/IEC13210: 1994 (E) ANSI/IEEE Std 1003.3-1991"
        PubId.new(publisher: "ISO/IEC/IEEE", number: "13210", year: "1994")
      when "J-STD-016-1995" then PubId.new(publisher: "IEEE", number: "016", year: "1995")
      when "Std 802.1ak-2007 (Amendment to IEEE Std 802.1QTM-2005)"
        PubId.new(publisher: "IEEE", number: "802", part: "1ak", year: "2007")
      when "IS0/IEC/IEEE 8802-11:2012/Amd.5:2015(E) (Adoption of IEEE Std 802.11af-2014)"
        PubId.new(publisher: "ISO/IEC/IEEE", number: "802", part: "11", year: "2012", amd: "5", year_amendment: "2015")
      when "National Electrical Safety Code, C2-2012 - Redline"
        PubId.new(publisher: "IEEE", number: "C2", year: "2012", redline: "true")
      when "National Electrical Safety Code, C2-2012" then PubId.new(publisher: "IEEE", number: "C2", year: "2012")
      when "2012 NESC Handbook, Seventh Edition" then PubId.new(publisher: "NESC", number: "HBK", year: "2012")
      when /^Amendment to IEEE Std 802\.11-2007 as amended by IEEE Std 802\.11k-2008/
        PubId.new(publisher: "IEEE", number: "802", part: "11u", year: "2007")
      when "Std 11073-10417-2009" then PubId.new(publisher: "IEEE", number: "11073", part: "10417", year: "2009")
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
      when /^([A-Z\/]+)#{APPROVAL}(?:\sDraft)?\sStd\s(\w+)\.(\d+)-\d{4}[^\/]*\/Cor\s?(\d)\/(D[\d\.]+),\s(?:\w+\s)?(\d{4})/o
        PubId.new(publisher: $1, approval: $2, number: $3, part: sp($4), corr: $5, draft: dn($6), year: $7)

      # publisher, number, part, corrigendum, draft, year, month
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)\.(\w+)-\d{4}\/Cor\s?(\d(?:-\d+x)?)[\/_]D([\d\.]+),\s?(\w+)\s(\d{4})/o
        PubId.new(publisher: $1, number: $2, part: $3, corr: $4, draft: dn($5), month: mn($6), year: $7)

      # publidsher1, number1, year1 publisher2, number2, draft, year2
      when /^([A-Z\/]+)\s(\w+)-(\d{4})\/([A-Z]+)\s([[:alnum:]]+)_D([\w.]+),\s(\d{4})/
        PubId.new([{ publisher: $1, number: $2, year: $3 }, { publisher: $4, number: $5, draft: dn($6), year: $7 }])

      when /^([A-Z\/]+)\s(#{STAGES})\s(\w+)[.-]([[:alnum:].-]+)[\s\/_]ED([\w.]+),\s(\w+)\s(\d{4})/o
        PubId.new(publisher: $1, stage: $2, number: $3, part: sp($4), edition: $5, month: mn($6), year: $7)

      # publidsher1, number1, publisher2, number2, draft, year
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)\/([A-Z]+)\s([[:alnum:]]+)_D([\d\.]+),\s\w+\s(\d{4})/o,
           /^([A-Z\/]+)\s(\w+)\sand\s([A-Z]+)(?:\sGuideline)?\s([[:alnum:]]+)\/D([\d\.]+),\s\w+\s(\d{4})/o
        PubId.new([{ publisher: $1, number: $2 }, { publisher: $3, number: $4, draft: dn($5), year: $6 }])

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
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)[.-]([\d-]+)\/Cor\s?(\d)[\/_]D([\d\.]+),\s(?:\w+\s)?(\d{4})/o,
           /^([A-Z\/]+)\s(\w+)[.-](\d+)-\d{4}\/Cor\s?(\d)(?:-|,\s|\/)D([\d.]+),?\s\w+\s(\d{4})/,
           /^([A-Z\/]+)\s(\w+)\.([[:alnum:].]+)[-_]Cor[\s-]?(\d)\/D([\d.]+),?\s\w+\s(\d{4})/
        PubId.new(publisher: $1, number: $2, part: sp($3), corr: $4, draft: dn($5), year: $6)
      when /^([A-Z\/]+)\s(\w+)\.(\d+)-\d{4}\/Cor(\d)-(\d{4})\/D([\d.]+)/ # "#{$1} #{$2}-#{$3}/Cor#{$4}/D#{$6}.#{$5}"
        PubId.new(publisher: $1, number: $2, part: $3, corr: $4, draft: dn($6), year: $5)

      # publisher, status, number, part, draft, year, month
      when /^([A-Z\/]+)(\sActive)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)[.-]([[:alnum:]\.]+)\s?[\/_]D([\w\.]+),?\s(\w+)(?:\s\d{1,2},)?\s?(\d{2,4})/o
        PubId.new(publisher: $1, status: $2, number: $3, part: sp($4), draft: dn($5), year: $7, month: mn($6))

      # publisher, approval, number, part, draft, year, month
      when /^([A-Z\/]+)(?:\sActive)?#{APPROVAL}(?:\sDraft)?#{STD}\s(\w+)[.-]([[:alnum:]\.]+)\s?[\/_]D([\w\.-]+),?\s(\w+)(?:\s\d{1,2},)?\s?(\d{2,4})/o
        PubId.new(publisher: $1, approval: $2, number: $3, part: sp($4), draft: dn($5), year: $7, month: mn($6))
      when /^([A-Z\/]+)\s(\w+)\.([\w.]+)\/D([\w.]+),?\s(\w+)[\s_](\d{4})(?:\s-\s\(|\s\(|_)(Unapproved|Approved)/
        PubId.new(publisher: $1, number: $2, part: sp($3), draft: dn($4), year: $6, month: mn($5), approval: $7)

      # publisher, approval, number, draft, year, month
      when /^([A-Z\/]+)\s(\w+)\/D([\w.]+),\s(\w+)\s(\d{4})\s-\s\(?(Approved|Unapproved)/
        PubId.new(publisher: $1, number: $2, draft: dn($3), year: $5, month: mn($4), approval: $6)

      # publisher, approval, number, part, draft, year
      when /^([A-Z\/]+)#{APPROVAL}(?:\sDraft)?#{STD}\s(\w+)[.-]([\w.]+)\s?[\/_\s]D([\w\.]+),?\s\w+\s?(\d{4})/o
        PubId.new(publisher: $1, approval: $2, number: $3, part: sp($4), draft: dn($5), year: $6)
      when /^([A-Z\/]+)\s(\w+)\.([\w.]+)\/D([\d.]+),?\s\w+[\s_](\d{4})(?:\s-\s\(|_|\s\()?#{APPROVAL}/o
        PubId.new(publisher: $1, number: $2, part: sp($3), draft: dn($4), year: $5, approval: $6)

      # publisher, stage, number, part, edition, year, month
      when /^([A-Z\/]+)\s(\w+)[.-]([[:alnum:].-]+)[\/_](#{STAGES})\s(\w+)\sedition,\s(\w+)\s(\d{4})/o
        PubId.new(publisher: $1, number: $2, part: sp($3), stage: $4, edition: en($5), month: mn($6), year: $7)

      # number, part, corrigendum, draft, year
      when /^(\w+)\.([\w.]+)-\d{4}[_\/]Cor\s?(\d)\/D([\w.]+),?\s\w+\s(?:\d{2},\s)?(\d{4})/
        PubId.new(number: $1, part: sp($2), corr: $3, draft: dn($4), year: $5)

      # publisher, approval, number, part, draft
      when /^([A-Z\/]+)\s(\w+)\.(\d+)\/D([\d.]+)\s\([^)]+\)\s-#{APPROVAL}/o
        PubId.new(publisher: $1, approval: $5, number: $2, part: $3, draft: dn($4))

      # publisher, number, part1, rev, draft, part2
      when /^([A-Z\/]+)#{STD}\s(\w+)\.([\d.]+)REV([a-z]+)_D([\w.]+)\sPart\s(\d)/o
        PubId.new(publisher: $1, number: $2, part: "#{sp($3)}-#{$6}", rev: $4, draft: dn($5))

      # publisher, number, part, draft, year, month
      when /^([A-Z\/]+)#{STD}\s(\w+)[.-]([[:alnum:].]+)[\/\s_]D([\d.]+)(?:,?\s|_)([[:alpha:]]+)[\s_]?(\d{4})/o
        PubId.new(publisher: $1, number: $2, part: sp($3), draft: dn($4), year: $6, month: mn($5))

      # publisher, stage, number, part, draft, year
      when /^([\w\/]+)\s(#{STAGES})\s(\w+)-([[:alnum:]]+)[\/_\s]D([\d.]+),\s\w+\s(\d{4})/o
        PubId.new(publisher: $1, stage: $2, number: $3, part: sp($4), draft: dn($5), year: $6)

      # publisher, number, part, rev, draft, year, month
      when /^([A-Z\/]+)\s(\w+)\.([\w.]+)-Rev\/D([\w.]+),\s(\w+)\s(\d{4})/
        PubId.new(publisher: $1, number: $2, part: sp($3), rev: "", draft: dn($4), year: $6, month: mn($5))

      # publisher, number, part, rev, draft, year
      when /^([A-Z\/]+)\s(\w+)\.([\d.]+)Rev(\w+)-D([\w.]+),\s\w+\s(\d{4})/
        PubId.new(publisher: $1, number: $2, part: sp($3), rev: $4, draft: dn($5), year: $6)

      # publisher, stage, number, part, edition, year
      when /^([A-Z\/]+)\s(#{STAGES})\s(\w+)[.-]([[:alnum:].-]+)[\/\s_]ED([\d.]+),\s(\d{4})/o
        PubId.new(publisher: $1, stage: $2, number: $3, part: sp($4), edition: $5, year: $6)

      # publisher, stage, number, draft, year, month
      when /^([A-Z\/]+)\s(\w+)\/(#{STAGES})[\/_]D([\w.]+),\s(\w+)\s(\d{4})/o
        PubId.new(publisher: $1, number: $2, stage: $3, draft: dn($4), year: $6, month: mn($5))

      # number, part, draft, year, month
      when /(\w+)[.-]([[:alnum:].]+)[\/\s_]D([\d.]+)(?:,?\s|_)([[:alpha:]]+)[\s_]?(\d{4})/
        PubId.new(publisher: "IEEE", number: $1, part: sp($2), draft: dn($3), year: $5, month: mn($4))

      # number, corrigendum, draft, year, month
      when /^(\w+)-\d{4}[\/_]Cor\s?(\d)[\/_]D([\w.]+),\s(\w+)\s(\d{4})/
        PubId.new(publisher: "IEEE", number: $1, corr: $2, draft: dn($3), month: mn($4), year: $5)

      # publisher, number, corrigendum, draft, year
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?\sStd\s(\w+)(?:-\d{4})?[\/_]Cor\s?(\d)\/D([\d\.]+),\s\w+\s(\d{4})/o
        PubId.new(publisher: $1, number: $2, corr: $3, draft: dn($4), year: $5)

      # publisher, number, part, rev, corrigendum, draft
      when /^([A-Z\/]+)\s(\w+)\.(\w+)-\d{4}-Rev\/Cor(\d)\/D([\d.]+)/
        PubId.new(publisher: $1, number: $2, part: $3, rev: "", corr: $4, draft: dn($5))

      # publisher, number, part, corrigendum, draft
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)\.([\w.]+)\/[Cc]or\s?(\d)\/D([\w\.]+)/o,
           /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)\.(\w+)-\d{4}\/Cor\s?(\d)[\/_]D([\d\.]+)/o
        PubId.new(publisher: $1, number: $2, part: sp($3), corr: $4, draft: dn($5))

      # publisher, number, part, corrigendum, year
      when /^([A-Z\/]+)#{STD}\s(\w+)[.-]([\w.]+)[:-]\d{4}[\/-]Cor[\s.]?(\d)[:-](\d{4})/o
        PubId.new(publisher: $1, number: $2, part: sp($3), corr: $4, year: $5)

      # publisher, number, part, draft, year
      when /^([\w\/]+)(?:\sActive)?#{APPROV}(?:\sDraft)?#{STD}\s(\w+)[.-]([[:alnum:]\.]+)(?:\s?\/\s?|_|,\s|-)D([\w\.]+)\s?,?\s\w+(?:\s\d{1,2},)?\s?(\d{2,4})/o,
           /^([A-Z\/]+)#{STD}\s(\w+)[.-]([\w.-]+)[\/\s]D([\w.]*)(?:-|,\s?\w+\s|\s\w+:|,\s)(\d{4})/o,
           /^([\w\/]+)(?:\sActive)?#{APPROV}(?:\sDraft)?#{STD}\s(\w+)[.-]([[:alnum:]\.]+)\sDraft\s([\w\.]+),\s\w+\s(\d{4})/o
        PubId.new(publisher: $1, number: $2, part: sp($3), draft: dn($4), year: $5)

      # publisher, approval, number, draft, year
      when /^([A-Z\/]+)#{APPROVAL}(?:\sDraft)?#{STD}\s([[:alnum:]]+)\s?[\/_]\s?D([\w\.]+),?\s\w+\s(\d{2,4})/o
        PubId.new(publisher: $1, approval: $2, number: $3, draft: dn($4), year: $5)
      when /^([A-Z\/]+)\s(\w+)\/D([\d.]+),\s\w+[\s_](\d{4})(?:\s-\s\(?|_)?#{APPROVAL}/o
        PubId.new(publisher: $1, number: $2, draft: dn($3), year: $4, approval: $5)

      # publisher, number, part, rev, draft
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)\.([\w.]+)[-\s\/]?REV-?(\w+)\/D([\d.]+)/o
        PubId.new(publisher: $1, number: $2, part: sp($3), rev: $4, draft: dn($5))
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)\.([\w.]+)-REV\/D([\d.]+)/o
        PubId.new(publisher: $1, number: $2, part: sp($3), rev: "", draft: dn($4))

      # publisher, number, part, rev, year
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?\sStd\s(\w+)\.(\d+)\/rev(\d+),\s\w+\s(\d+)/o
        PubId.new(publisher: $1, number: $2, part: sp($3), rev: $4, year: $5)

      # publisher, stage, number, draft, year
      when /^([\w\/]+)\s(#{STAGES})\s([[:alnum:]]+)[\/_]D([\w.]+),(?:\s\w+)?\s(\d{4})/o
        PubId.new(publisher: $1, stage: $2, number: $3, draft: dn($4), year: $5)

      # publisher, stage, number, part, year, month
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)[.-]([[:alnum:].-]+)(?:[\/_-]|,\s)(#{STAGES}),?\s(\w+)\s(\d{4})/o
        PubId.new(publisher: $1, number: $2, part: sp($3), stage: $4, year: $6, month: mn($5))
      when /^([A-Z\/]+)\s(#{STAGES})\s(\w+)[.-](\w+),\s(\w+)\s(\d{4})/o
        PubId.new(publisher: $1, number: $3, part: sp($4), stage: $2, year: $6, month: mn($5))

      # publisher, number, part, edition, year, month
      when /^([A-Z\/]+)\s(\w+)[.-]([\w.-]+)[\/\s]ED([\d+]),\s(\w+)\s(\d{4})/
        PubId.new(publisher: $1, number: $2, part: sp($3), edition: $4, month: mn($5), year: $6)

      # publisher, stage, number, part, year
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)[.-](\d+)[\/_-](#{STAGES}),?\s\w+\s(\d{4})/o,
           /^([A-Z\/]+)\s(\w+)-(\d+)[\/-](#{STAGES})(?:_|,\s|-)\w+\s?(\d{4})/o,
           /^([A-Z\/]+)\s(\w+)[.-](\d+)[\/-_](#{STAGES})[\s-](\d{4})/o
        PubId.new(publisher: $1, number: $2, part: sp($3), stage: $4, year: $5)
      when /^([A-Z\/]+)\s(#{STAGES})\s(\w+)-([\w-]+),\s(\d{4})/o
        PubId.new(publisher: $1, number: $3, part: sp($4), stage: $2, year: $5)

      # publisher, stage, number, year, month
      when /^([A-Z\/]+)\s(#{STAGES})\s(\w+)(?:\s\g<2>)?,\s(\w+)\s(\d{4})/o
        PubId.new(publisher: $1, number: $3, stage: $2, year: $5, month: mn($4))
      when /^([A-Z\/]+)\s([[:alnum:]]+)(?:\s|_|\/\s?)?(#{STAGES}),?\s(\w+)\s(\d{4})/o
        PubId.new(publisher: $1, number: $2, stage: $3, year: $5, month: mn($4))

      # publisher, stage, number, part, draft
      when /^([A-Z\/]+)[.-]([[:alnum:].-]+)[\/_]D([[:alnum:].]+)[\/_](#{STAGES})/o,
        /^(\w+)[.-]([[:alnum:].]+)[\/\s_]D([\d.]+)_(#{STAGES})/o
        PubId.new(publisher: "IEEE", number: $1, part: sp($2), draft: dn($3), stage: $4)

      # publisher, stage, number, year
      when /^([A-Z\/]+)\s(#{STAGES})\s(\w+)(?:,\s\w+\s|:)(\d{4})/o
        PubId.new(publisher: $1, number: $3, stage: $2, year: $4)
      when /^([A-Z\/]+)\s(\w+)(?:\/|,\s)(#{STAGES})-(\d{4})/o
        PubId.new(publisher: $1, number: $2, stage: $3, year: $4)

      # publisher, stage, number, part
      when /^([A-Z\/]+)\s(\w+)-([\w-]+)[\s-](#{STAGES})/o
        PubId.new(publisher: $1, number: $2, part: $3, stage: $4)
      when /^([A-Z\/]+)\s(\w+)-(#{STAGES})-(\w+)/o
        PubId.new(publisher: $1, number: $2, part: $4, stage: $3)
      when /^([A-Z\/]+)\s(#{STAGES})\s(\w+)[.-]([[:alnum:].-]+)/o
        PubId.new(publisher: $1, number: $3, part: sp($4), stage: $2)

      # publisher, number, corrigendum, year
      when /^([A-Z\/]+)#{STD}\s(\w+)-\d{4}\/Cor\s?(\d)-(\d{4})/o
        PubId.new(publisher: $1, number: $2, corrigendum: $3, year: $4)

      # publisher, number, rev, draft
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)-REV\/D([\d.]+)/o
        PubId.new(publisher: $1, number: $2, rev: "", draft: dn($3))

      # publisher, number, part, year, month
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)-([\w-]+),\s(\w+)\s?(\d{4})/o,
           /^([A-Z\/]+)\sStd\s(\w+)\.(\w+)-\d{4}\/INT,?\s(\w+)\.?\s(\d{4})/
        PubId.new(publisher: $1, number: $2, part: sp($3), year: $5, month: mn($4))

      # publisher, number, part, amendment, year
      when /^([A-Z\/]+)#{STD}\s(\w+)-(\w+)[:-](\d{4})\/Amd(?:\s|.\s?)?(\d)/o
        PubId.new(publisher: $1, number: $2, part: sp($3), amd: $5, year: $4)

      # publisher, number, part, year, redline
      when /^([A-Z\/]+)#{STD}\s(\w+)[.-]([\w.]+)[:-](\d{4}).*?\s-\s(Redline)/o,
           /^([A-Z\/]+)#{STD}\s(\w+)[.-]([\w.-]+):(\d{4}).*?\s-\s(Redline)/o
        PubId.new(publisher: $1, number: $2, part: $3, year: $4, redline: true)

      # publisher, number, part, year
      when /^([A-Z\/]+)\s(\w+)-(\d{1,3}),\s\w+\s(\d{4})/,
           /^([A-Z\/]+)#{STD}\s(\w+)[.-](?!(?:19|20)\d{2}\D)([\w.]+)(?:,\s\w+\s|-|:|,\s|\.|:)(\d{4})/o,
           /^([A-Z\/]+)#{STD}\s(\w+)[.-](?!(?:19|20)\d{2}\D)([\w.-]+)(?:,\s\w+\s|:|,\s|\.|:)(\d{4})/o,
           /^([A-Z\/]+)#{STD}\sNo(?:\.?\s|\.)(\w+)\.(\d+)\s?-(?:\w+\s)?(\d{4})/o
        PubId.new(publisher: $1, number: $2, part: sp($3), year: $4)

      # publisher, number, edition, year
      when /^([A-Z\/]+)\s(\w+)\s(\w+)\sEdition,\s\w+\s(\d+)/,
           /^([A-Z\/]+)\s(\w+)[\/_]ED([\d.]+),\s(\d{4})/
        PubId.new(publisher: $1, number: $2, edition: en($3), year: $4)

      # publisher, number, part, conformance, draft
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)\.([[:alnum:].]+)[\/-]Conformance(\d+)[\/_]D([\w\.]+)/o
        PubId.new(publisher: $1, number: $2, part: "#{sp($3)}-#{$4}", draft: dn($5))

      # publisher, number, part, conformance, year
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)\.([[:alnum:].]+)\s?\/\s?Conformance(\d+)-(\d{4})/o
        PubId.new(publisher: $1, number: $2, part: "#{sp($3)}-#{$4}", year: $5)

      # publisher, number, part, draft
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)\.([[:alnum:].]+)[^\/]*\/D([[:alnum:]\.]+)/o,
           /^([A-Z\/]+)\s(\w+)[.-]([[:alnum:]-]+)[\s_]D([\d.]+)/,
           /^([A-Z\/]+)\s(\w+)-(\w+)\/D([\w.]+)/
        PubId.new(publisher: $1, number: $2, part: sp($3), draft: dn($4))

      # number, part, draft, year
      when /^(\w+)[.-]([[:alnum:].-]+)(?:\/|,\s|_)D([\d.]+),?\s(?:\w+,?\s)?(\d{4})/
        PubId.new(publisher: "IEEE", number: $1, part: sp($2), draft: dn($3), year: $4)

      # publisher, number, draft, year, month
      when /^([A-Z\/]+)\s(\w+)[\/_]D([\d.]+),\s(\w+)\s(\d{4})/
        PubId.new(publisher: $1, number: $2, draft: dn($3), year: $5, month: mn($4))

      # publisher, number, draft, year
      when /^([\w\/]+)(?:\sActive)?#{APPROV}(?:\sDraft)?#{STD}\s([[:alnum:]]+)\s?[\/_]\s?D([\w\.-]+),?\s(?:\w+\s)?(\d{2,4})/o,
           /^([\w\/]+)(?:\sActive)?#{APPROV}(?:\sDraft)?#{STD}\s([[:alnum:]]+)\/?D?([\d\.]+),?\s\w+\s(\d{4})/o,
           /^([A-Z\/]+)\s(\w+)\/Draft\s([\d.]+),\s\w+\s(\d{4})/
        PubId.new(publisher: $1, number: $2, draft: dn($3), year: yn($4))
      when /^([A-Z\/]+)\sStd\s(\w+)-(\d{4})\sDraft\s([\d.]+)/
        PubId.new(publisher: $1, number: $2, draft: dn($4), year: $3)

      # publisher, approval, number, draft
      when /^([A-Z\/]+)#{APPROVAL}(?:\sDraft)?#{STD}\s([[:alnum:]]+)[\/_]D([\w.]+)/o
        PubId.new(publisher: $1, approval: $2, number: $3, draft: dn($4))

      # number, draft, year
      when /^(\w+)\/D([\w.+]+),?\s\w+,?\s(\d{4})/
        PubId.new(publisher: "IEEE", number: $1, draft: dn($2), year: $3)

      # number, rev, draft
      when /^(\w+)-REV\/D([\d.]+)/o
        PubId.new(publisher: "IEEE", number: $1, rev: "", draft: dn($2))

      # publisher, number, draft
      when /^([\w\/]+)#{APPROV}(?:\sDraft)?#{STD}\s([[:alnum:]]+)[\/_]D([\w.]+)/o
        PubId.new(publisher: $1, number: $2, draft: dn($3))

      # publisher, number, year, month
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)(?:-\d{4})?,\s(\w+)\s(\d{4})/o
        PubId.new(publisher: $1, number: $2, year: $4, month: mn($3))

      # publisher, number, year, redline
      when /^([A-Z\/]+)#{STD}\s(\w+)[:-](\d{4}).*?\s-\s(Redline)/o
        PubId.new(publisher: $1, number: $2, year: $3, redline: true)

      # publisher, number, year
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)(?:-|:|,\s(?:\w+\s)?)(\d{2,4})/o,
           /^(\w+)#{APPROV}(?:\sDraft)?\sStd\s(\w+)\/\w+\s(\d{4})/o,
           /^([\w\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)\/FCD-\w+(\d{4})/o,
           /^(\w+)#{STD}\sNo(?:\.?\s|\.)(\w+)\s?(?:-|,\s)(?:\w+\s)?(\d{4})/o,
           /^([A-Z\/]+)\sStd\s(\w+)\/INT-(\d{4})/
        PubId.new(publisher: $1, number: $2, year: yn($3))
      when /^ANSI\/\sIEEE#{STD}\s(\w+)-(\d{4})/o
        PubId.new(publisher: "ANSI/IEEE", number: $1, year: $2)

      # publisher, number, part
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}\s(\w+)[.-]([\d.]+)/o
        PubId.new(publisher: $1, number: $2, part: sp($3))

      # number, part, draft
      when /^(\w+)\.([\w.]+)\/D([\w.]+)/
        PubId.new(publisher: "IEEE", number: $1, part: sp($2), draft: dn($3))

      # number, part, year
      when /^(\d{2})\sIRE\s(\w+)[\s.](\w+)/ # "IRE #{$2}-#{$3}.#{yn $1}"
        PubId.new(publisher: "IRE", number: $2, part: $3, year: yn($1))
      when /^(\w+)\.(\w+)-(|d{4})/ then PubId.new(publisher: "IEEE", number: $1, part: $2, year: $3)

      # number, year
      when /^(\w+)-(\d{4})\D/ then PubId.new(publisher: "IEEE", number: $1, year: $2)

      # publisher, number
      when /^([A-Z\/]+)#{APPROV}(?:\sDraft)?#{STD}(?:\sNo\.?)?\s(\w+)/o
        PubId.new(publisher: $1, number: $2)

      else
        Util.warn %{Use stdnumber "#{stdnumber}" for normtitle "#{normtitle}"}
        PubId.new(publisher: "IEEE", number: stdnumber)
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
      return year if year.size == 4

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
      draftnum.sub(/^\./, "").gsub "-", "."
    end

    extend RawbibIdParser
  end
end
