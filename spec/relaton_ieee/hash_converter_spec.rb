RSpec.describe RelatonIeee::HashConverter do
  it "crate bibitem form hash" do
    file = "spec/fixtures/ieee-std.yaml"
    hash = YAML.safe_load File.read(file, encoding: "UTF-8")
    item = RelatonIeee::IeeeBibliographicItem.from_hash hash
    expect(item.to_hash).to eq hash
  end

  it "convert relation" do
    hash = {
      "title" => { "type" => "main", "content" => "title" },
      "relation" => {
        "type" => "updatedBy",
        "bibitem" => { "formattedref" => { "content" => "Reference" } },
      },
    }
    item = RelatonIeee::HashConverter.hash_to_bib hash
    expect(item[:relation][0][:bibitem]).to be_instance_of(
      RelatonIeee::IeeeBibliographicItem,
    )
  end
end
