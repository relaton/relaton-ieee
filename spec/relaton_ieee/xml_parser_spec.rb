RSpec.describe RelatonIeee::XMLParser do
  it "parse XML" do
    xml = File.read "spec/fixtures/ieee_528_2019.xml", encoding: "UTF-8"
    item = RelatonIeee::XMLParser.from_xml xml
    expect(item.to_xml(bibdata: true)).to be_equivalent_to xml
  end

  it "parse editorial group" do
    elm = Nokogiri::XML <<~XML
      <ext>
        <editorialgroup>
          <society>Society</society>
          <balloting-group type="entity">Group</balloting-group>
          <working-group>Working group</working-group>
          <committee>Committee1</committee>
          <committee>Committee2</committee>
        </editorialgroup>
      </ext>
    XML
    eg = described_class.send :parse_editorialgroup, elm
    expect(eg).to be_instance_of RelatonIeee::EditorialGroup
    expect(eg.society).to eq "Society"
    expect(eg.balloting_group).to be_instance_of RelatonIeee::BallotingGroup
    expect(eg.balloting_group.content).to eq "Group"
    expect(eg.balloting_group.type).to eq "entity"
    expect(eg.working_group).to eq "Working group"
    expect(eg.committee).to eq ["Committee1", "Committee2"]
  end
end
