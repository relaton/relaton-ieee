RSpec.describe RelatonIeee do
  it "has a version number" do
    expect(RelatonIeee::VERSION).not_to be nil
  end

  it "fetch hit" do
    VCR.use_cassette "ieee_528_2019" do
      hit_collection = RelatonIeee::IeeeBibliography.search("IEEE 528-2019")
      expect(hit_collection.fetched).to be_falsy
      expect(hit_collection.fetch).to be_instance_of RelatonOgc::HitCollection
      expect(hit_collection.fetched).to be_truthy
      expect(hit_collection.first).to be_instance_of RelatonOgc::Hit
    end
  end
end
