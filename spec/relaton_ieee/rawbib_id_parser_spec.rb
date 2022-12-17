RSpec.describe RelatonIeee::RawbibIdParser do
  # it do
  #   ids = {}
  #   File.readlines("spec/fixtures/normtitles.txt", encoding: "UTF-8").each do |nt|
  #     id = RelatonIeee::RawbibIdParser.parse(nt.strip)
  #     # expect(id).not_to be_nil
  #     # expect(ids[id]).to be_nil
  #     ids[id] ||= nt.strip if id
  #   end
  #   ids
  # end

  # it do
  #   pid = RelatonIeee::RawbibIdParser.parse "IEEE Std 802.15.4j-2013 (Amendment to IEEE Std 802.15.4-2011 as amended by IEEE Std 802.15.4e-2012, IEEE Std 802.15.4f-2012, and IEEE Std 802.15.4g-2012)"
  #   id = pid.to_s
  #   id
  # end

  context "converts 2 digit year to 4 digit year" do
    it "4 digit year" do
      y = (Date.today.year + 1).to_s
      expect(described_class.yn(y)).to eq y
    end

    it "this century" do
      y = Date.today.year.to_s
      expect(described_class.yn(y[2..3])).to eq y
    end

    it "previous century" do
      y = Date.today.year.to_s[2..4].to_i + 1
      expect(described_class.yn(y.to_s)).to eq "19#{y}"
    end
  end

  context "coverts edition name to number" do
    it "First" do
      expect(described_class.en("First")).to eq 1
    end

    it "Second" do
      expect(described_class.en("Second")).to eq 2
    end

    it "3rd" do
      expect(described_class.en("3")).to eq "3"
    end
  end

  it "parse sdtnumber" do
    pubid = described_class.parse("", "802.15.4j-2013")
    expect(pubid.to_s).to eq "IEEE 802.15.4j-2013"
  end

  shared_examples "parse normtitle" do |nt, id|
    it "parse #{nt}" do
      expect(described_class.parse(nt, "").to_s).to eq id
    end
  end

  it_behaves_like "parse normtitle", "A.I.E.E. No. 15 May-1928", "AIEE 15-1928-05"
  it_behaves_like "parse normtitle", "IEEE Std P1073.1.3.4/D3.0", "IEEE P11073.00101"
  it_behaves_like "parse normtitle", "IEEE P1073.2.1.1/D08", "ISO/IEEE P1073.2-1-1/D-08"
  it_behaves_like "parse normtitle", "IEEE P802.1Qbu/03.0, July 2015", "IEEE P802.1Qbu/D-3.0-2015"
  it_behaves_like "parse normtitle", "IEEE P11073-10422/04, November 2015", "IEEE P11073.10422/D-04-2015"
  it_behaves_like "parse normtitle", "IEEE P802.11aqTM/013.0 October 2017", "IEEE P802.11aqTM/D-13.0-2017"
  it_behaves_like "parse normtitle", "IEEE P844.3/C22.2 293.3/D0, August 2018", "IEEE P844.3/C22.2.293.3-2018"
  it_behaves_like "parse normtitle", "IEEE P844.3/C22.2 293.3/D1, November 2018", "IEEE P844.3/C22.2.293.3/D-1-2018"
  it_behaves_like "parse normtitle", "AIEE No 431 (105) -1958", "AIEE 431-1958"
  it_behaves_like "parse normtitle", "IEEE 1076-CONC-I99O", "IEEE 1076-199O"
  it_behaves_like "parse normtitle", "IEEE Std 960-1993, IEEE Std 1177-1993", "IEEE 960/1177-1993"
  it_behaves_like "parse normtitle", "IEEE P802.11ajD8.0, August 2017", "IEEE P802.11aj/D-8.0-2017"
  it_behaves_like "parse normtitle", "IEEE P802.11ajD9.0, November 2017", "IEEE P802.11aj/D-9.0-2017"
  it_behaves_like "parse normtitle", "ISO/IEC/IEEE P29119-4-DISMay2013", "ISO/IEC/IEEE DIS P29119.4-2013"
  it_behaves_like "parse normtitle", "IEEE-P15026-3-DIS-January 2015", "IEEE DIS P15026-2015"
  it_behaves_like "parse normtitle", "ANSI/IEEE PC63.7/D rev17, December 2014", "ANSI/IEEE PC63.7/D-/R-17-2014"
  it_behaves_like "parse normtitle", "IEC/IEEE P62271-37-013:2015 D13.4", "IEC/IEEE P62271.37-013/D-13.4-2015"
  it_behaves_like "parse normtitle", "PC37.30.2/D043 Rev 18, May 2015", "IEEE PC37.30-2/D-043/R-18-2015"
  it_behaves_like "parse normtitle", "IEC/IEEE FDIS 62582-5 IEC/IEEE 2015", "IEC/IEEE FDIS 62582.5-2015"
  it_behaves_like "parse normtitle", "ISO/IEC/IEEE P15289:2016, 3rd Ed FDIS/D2", "ISO/IEC/IEEE FDIS P15289./E-3/D-2-2016"
  it_behaves_like "parse normtitle", "IEEE P802.15.4REVi/D09, April 2011 (Revision of IEEE Std 802.15.4-2006)", "IEEE Approved P802.15.4/D-09/R-i-2013-04"
  it_behaves_like "parse normtitle", "Draft IEEE P802.15.4REVi/D09, April 2011 (Revision of IEEE Std 802.15.4-2006)", "IEEE P802.15.4/D-09/R-i-2011-04"
  it_behaves_like "parse normtitle", "ISO/IEC/IEEE DIS P42020:201x(E), June 2017", "ISO/IEC/IEEE DIS P42020-2017-06"
  it_behaves_like "parse normtitle", "IEEE/IEC P62582 CD2 proposal, May 2017", "IEEE/IEC CD2 P62582-2017-05"
  it_behaves_like "parse normtitle", "ISO/IEC/IEEE P16326:201x WD.4a, July 2017", "ISO/IEC/IEEE P16326/D-4a-2017-07"
  it_behaves_like "parse normtitle", "ISO/IEC/IEEE CD.1 P21839, October 2017", "ISO/IEC/IEEE CD1 P21839-2017-10"
  it_behaves_like "parse normtitle", "IEEE P3001.2/D5, August 2017", "IEEE P3001.2/D-5-2017-01"
  it_behaves_like "parse normtitle", "P3001.2/D5, August 2017", "IEEE P3001.2/D-5-2017-12"
  it_behaves_like "parse normtitle", "ISO/IEC/IEEE P16326:201x WD5, December 2017", "ISO/IEC/IEEE P16326/D-5-2017-12"
  it_behaves_like "parse normtitle", "ISO/IEC/IEEE DIS P16326/201x, December 2018", "ISO/IEC/IEEE DIS P16326-2018-12"
  it_behaves_like "parse normtitle", "ISO/IEC/IEEE/P21839, 2019(E)", "ISO/IEC/IEEE P21839-2019"
  it_behaves_like "parse normtitle", "ISO/IEC/IEEE P42020/V1.9, August 2018", "ISO/IEC/IEEE P42020-2018-08"
  it_behaves_like "parse normtitle", "ISO/IEC/IEEE CD2 P12207-2: 201x(E), February 2019", "ISO/IEC/IEEE CD2 P12207.2-2019-02"
  it_behaves_like "parse normtitle", "ISO/IEC/IEEE P42010.WD4:2019(E)", "ISO/IEC/IEEE P42010/D-4-2019"
  it_behaves_like "parse normtitle", "IEC/IEEE P63195_CDV/V3, February 2020", "IEC/IEEE CDV P63195-2020-02"
  it_behaves_like "parse normtitle", "ISO /IEC/IEEE P24774_D1, February 2020", "ISO/IEC/IEEE P24774/D-1-2020-02"
  it_behaves_like "parse normtitle", "IEEE/ISO/IEC P42010.CD1-V1.0, April 2020", "IEEE/ISO/IEC CD1 P42010-2020-04"
  it_behaves_like "parse normtitle", "ISO/IEC/IEEE/P16085_DIS, March 2020", "ISO/IEC/IEEE DIS P16085-2020-03"
  it_behaves_like "parse normtitle", "ISO/IEC/IEEE P24774/DIS, July 2020", "ISO/IEC/IEEE DIS P24774-2020-07"
  it_behaves_like "parse normtitle", "ANSI/IEEE Std: Outdoor Apparatus Bushings", "ANSI/IEEE 21-1976-11"
  it_behaves_like "parse normtitle", "Unapproved Draft Std ISO/IEC FDIS 15288:2007(E) IEEE P15288/D3,", "ISO/IEC/IEEE FDIS P15288/D-3-2007"
  it_behaves_like "parse normtitle", "Draft National Electrical Safety Code, January 2016", "IEEE PC2-2016-01"
  it_behaves_like "parse normtitle", "ANSI/IEEE-ANS-7-4.3.2-1982", "ANSI/IEEE/ANS 7.4-3-2-1982"
  it_behaves_like "parse normtitle", "IEEE Unapproved Draft Std P802.1AB/REVD2.2, Dec 2007", "IEEE P802.1AB/D-2.2/R--2007-12"
  it_behaves_like "parse normtitle", "International Standard ISO/IEC 8802-9: 1996(E) ANSI/IEEE Std 802.9, 1996 Edition", "ISO/IEC/IEEE 802.9-1996"
  it_behaves_like "parse normtitle", "ISO/IEC13210: 1994 (E) ANSI/IEEE Std 1003.3-1991", "ISO/IEC/IEEE 13210-1994"
  it_behaves_like "parse normtitle", "J-STD-016-1995", "IEEE 016-1995"
  it_behaves_like "parse normtitle", "Std 802.1ak-2007 (Amendment to IEEE Std 802.1QTM-2005)", "IEEE 802.1ak-2007"
  it_behaves_like "parse normtitle", "IS0/IEC/IEEE 8802-11:2012/Amd.5:2015(E) (Adoption of IEEE Std 802.11af-2014)", "ISO/IEC/IEEE 802.11/Amd5-2012"
  it_behaves_like "parse normtitle", "National Electrical Safety Code, C2-2012 - Redline", "IEEE C2-2012 Redline"
  it_behaves_like "parse normtitle", "National Electrical Safety Code, C2-2012", "IEEE C2-2012"
  it_behaves_like "parse normtitle", "2012 NESC Handbook, Seventh Edition", "NESC HBK-2012"
  it_behaves_like "parse normtitle", "Amendment to IEEE Std 802.11-2007 as amended by IEEE Std 802.11k-2008...", "IEEE 802.11u-2007"
  it_behaves_like "parse normtitle", "Std 11073-10417-2009", "IEEE 11073.10417-2009"
  it_behaves_like "parse normtitle", "ANSI/ IEEE C37.23-1969", "ANSI/IEEE C37.23-1969"
  it_behaves_like "parse normtitle", "ISO /IEC/IEEE P24774_D3, January 2021", "ISO/IEC/IEEE P24774/D-3-2021-01"
  it_behaves_like "parse normtitle", "Nuclear EQ Sourcebook and Supplement", "IEEE 7438946"
end
