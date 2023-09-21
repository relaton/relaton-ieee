describe RelatonIeee::BallotingGroup do
  context "initialize" do
    it "warn when type is invalid" do
      expect do
        described_class.new type: "invalid", content: "Group"
      end.to output("[relaton-ieee] WARNING: type of Balloting group must be one of `individual`, `entity`\n").to_stderr
    end
  end

  context "instance methods" do
    subject { described_class.new type: "entity", content: "Group" }

    it "#to_xml" do
      builder = Nokogiri::XML::Builder.new { |b| subject.to_xml(b) }
      expect(builder.to_xml).to be_equivalent_to <<~XML
        <balloting-group type="entity">Group</balloting-group>
      XML
    end

    it "#to_hash" do
      expect(subject.to_hash).to eq("type" => "entity", "content" => "Group")
    end

    it "#to_asciibib" do
      expect(subject.to_asciibib).to eq <<~BIB
        balloting-group.type:: entity
        balloting-group.content:: Group
      BIB
    end
  end
end
