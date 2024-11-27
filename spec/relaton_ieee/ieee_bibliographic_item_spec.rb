RSpec.describe RelatonIeee::IeeeBibliographicItem do
  it "returns AsciiBib" do
    input = "spec/fixtures/ieee_528_2019.yaml"
    hash = YAML.safe_load File.read(input, encoding: "UTF-8")
    bib_hash = RelatonIeee::HashConverter.hash_to_bib hash
    item = RelatonIeee::IeeeBibliographicItem.new(**bib_hash)
    bib = item.to_asciibib
    file = "spec/fixtures/asciibib.adoc"
    File.write file, bib, encodint: "UTF-8" unless File.exist? file
    expect(bib).to eq File.read(file, encoding: "UTF-8")
  end

  it "returns BibXML" do
    input = "spec/fixtures/ieee_528_2019.yaml"
    hash = YAML.safe_load File.read(input, encoding: "UTF-8")
    bib_hash = RelatonIeee::HashConverter.hash_to_bib hash
    item = RelatonIeee::IeeeBibliographicItem.new(**bib_hash)
    xml = item.to_bibxml
    file = "spec/fixtures/bibxml.xml"
    File.write file, xml, encoding: "UTF-8" unless File.exist? file
    expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8")
  end

  it "warn when subdoctype is invalid" do
    expect do
      described_class.new docsubtype: "invalid"
    end.to output(
      "[relaton-ieee] WARN: Invalid docsubtype: `invalid`. It should be one of: " \
      "`amendment`, `corrigendum`, `erratum`.\n",
    ).to_stderr_from_any_process
  end
end
