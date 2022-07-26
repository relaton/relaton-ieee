describe RelatonIeee::EditorialGroup do
  context "initialize" do
    it "raises ArgumentError when :committee is not an Array" do
      expect do
        described_class.new
      end.to raise_error ArgumentError, ":committee is required"
    end

    it "raises ArgumentError when :committee is empty" do
      expect do
        described_class.new committee: []
      end.to raise_error ArgumentError, ":committee is required"
    end

    it "create BallotingGroup from hash" do
      bg = { type: "individual", content: "Group" }
      expect(RelatonIeee::BallotingGroup).to receive(:new).with(bg).and_call_original
      described_class.new committee: ["committee"], balloting_group: bg
    end
  end

  context "instance methods" do
    subject do
      described_class.new committee: ["Committee"],
                          society: "Society",
                          working_group: "Working group",
                          balloting_group: { type: "entity", content: "Group" }
    end

    it "#to_xml" do
      builder = Nokogiri::XML::Builder.new { |b| subject.to_xml(b) }
      expect(builder.to_xml).to be_equivalent_to <<~XML
        <editorialgroup>
          <society>Society</society>
          <balloting-group type="entity">Group</balloting-group>
          <working-group>Working group</working-group>
          <committee>Committee</committee>
        </editorialgroup>
      XML
    end
  end
end
