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

  it "get document" do
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
end
