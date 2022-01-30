RSpec.describe RelatonIeee::BibXMLParser do
  it "return docidentifier type" do
    expect(RelatonIeee::BibXMLParser.pubid_type("")).to eq "IEEE"
  end
end
