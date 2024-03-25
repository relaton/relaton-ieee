describe RelatonIeee::DocumentStatus do
  it "warn when stage is invalid" do
    expect do
      described_class::Stage.new value: "invalid"
    end.to output(
      "[relaton-ieee] WARN: Stage value must be one of: `draft`, `approved`, `superseded`, `withdrawn`\n",
    ).to_stderr_from_any_process
  end
end
