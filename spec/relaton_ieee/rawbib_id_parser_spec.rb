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
end
