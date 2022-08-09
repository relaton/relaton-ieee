RSpec.describe RelatonIeee::IeeeBibliographicItem do
  let(:type) { "invalid" }

  it "returns AsciiBib" do
    file = "spec/fixtures/ieee_528_2019.yaml"
    hash = YAML.safe_load File.read(file, encoding: "UTF-8")
    bib_hash = RelatonIeee::HashConverter.hash_to_bib hash
    item = RelatonIeee::IeeeBibliographicItem.new(**bib_hash)
    bib = item.to_asciibib
    file = "spec/fixtures/asciibib.adoc"
    File.write file, bib, encodint: "UTF-8" unless File.exist? file
    expect(bib).to eq File.read(file, encoding: "UTF-8")
  end

  it "warn when doctype is invalid" do
    expect do
      described_class.new doctype: type
    end.to output(
      "[relaton-ieee] invalid doctype \"#{type}\". It should be one of: " \
      "guide, recommended-practice, standard.\n",
    ).to_stderr
  end

  it "warn when subdoctype is invalid" do
    expect do
      described_class.new docsubtype: type
    end.to output(
      "[relaton-ieee] invalid docsubtype \"#{type}\". It should be one of: " \
      "amendment, corrigendum, erratum.\n",
    ).to_stderr
  end
end
