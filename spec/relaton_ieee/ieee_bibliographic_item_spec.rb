RSpec.describe RelatonIeee::IeeeBibliographicItem do
  let(:type) { "invalid" }
  before { RelatonIeee.instance_variable_set :@configuration, nil }

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

  it "warn when doctype is invalid" do
    expect do
      described_class.new doctype: type
    end.to output(
      "[relaton-ieee] Invalid doctype: `#{type}`. It should be one of: " \
      "`guide`, `recommended-practice`, `standard`, `witepaper`, `redline`, `other`.\n",
    ).to_stderr
  end

  it "warn when subdoctype is invalid" do
    expect do
      described_class.new docsubtype: type
    end.to output(
      "[relaton-ieee] Invalid docsubtype: `#{type}`. It should be one of: " \
      "`amendment`, `corrigendum`, `erratum`.\n",
    ).to_stderr
  end
end
