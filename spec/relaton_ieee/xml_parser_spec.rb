RSpec.describe RelatonIeee::XMLParser do
  it "parse XML" do
    xml = File.read "spec/fixtures/ieee_528_2019.xml", encoding: "UTF-8"
    item = RelatonIeee::XMLParser.from_xml xml
    expect(item.to_xml(bibdata: true)).to be_equivalent_to xml
  end
end
