RSpec.describe RelatonIeee do
  it "has a version number" do
    expect(RelatonIeee::VERSION).not_to be nil
  end

  it "returs grammar hash" do
    hash = RelatonIeee.grammar_hash
    expect(hash).to be_instance_of String
    expect(hash.size).to eq 32
  end

  it "fetch hits" do
    VCR.use_cassette "ieee_528_2019" do
      hit_collection = RelatonIeee::IeeeBibliography.search("IEEE 528-2019")
      expect(hit_collection.fetched).to be false
      expect(hit_collection.fetch).to be_instance_of RelatonIeee::HitCollection
      expect(hit_collection.fetched).to be true
      expect(hit_collection.first).to be_instance_of RelatonIeee::Hit
    end
  end

  context "get document" do
    it "by refercence with year" do
      VCR.use_cassette "ieee_528_2019" do
        result = RelatonIeee::IeeeBibliography.get "IEEE 528-2019"
        expect(result).to be_instance_of RelatonIeee::IeeeBibliographicItem
        file = "spec/fixtures/ieee_528_2019.xml"
        xml = result.to_xml bibdata: true
        File.write file, xml, encoding: "UTF-8" unless File.exist? file
        expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8").
          gsub /(?<=<fetched>)\d{4}-\d{2}-\d{2}/, Date.today.to_s
      end
    end

    it "by reference without year" do
      VCR.use_cassette "ieee_528_no_year" do
        result = RelatonIeee::IeeeBibliography.get "IEEE 528"
        expect(result.docidentifier.first.id).to eq "528-2019"
      end
    end

    it "by reference and wrong year" do
      VCR.use_cassette "ieee_528" do
        expect do
          result = RelatonIeee::IeeeBibliography.get "IEEE 528", "2018"
          expect(result).to be_nil
        end.to output(/no match found online for IEEE 528 year 2018/).to_stderr
      end
    end
  end
end
