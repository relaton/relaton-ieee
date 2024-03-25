describe RelatonIeee::DocumentType do
  it "warn when doctype is invalid" do
    expect do
      described_class.new type: "invalid"
    end.to output(
      "[relaton-ieee] WARN: Invalid doctype: `invalid`. It should be one of: " \
      "`guide`, `recommended-practice`, `standard`, `witepaper`, `redline`, `other`.\n",
    ).to_stderr_from_any_process
  end
end
