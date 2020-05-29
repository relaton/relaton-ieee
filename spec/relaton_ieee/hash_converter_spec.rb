RSpec.describe RelatonIeee::HashConverter do
  it "crate bibitem form hash" do
    file = "spec/fixtures/ieee_528_2019.yaml"
    hash = YAML.safe_load File.read(file, encoding: "UTF-8")
    bib = RelatonIeee::HashConverter.hash_to_bib hash
    item = RelatonIeee::IeeeBibliographicItem.new bib
    expect(item.to_hash).to eq hash
  end
end
