describe RelatonIeee::DocumentStatus do
  before { RelatonIeee.instance_variable_set :@configuration, nil }

  it "warn when stage is invalid" do
    expect do
      described_class::Stage.new value: "invalid"
    end.to output(
      "[relaton-ieee] Stage value must be one of `draft`, `approved`, `superseded`, `withdrawn`\n",
    ).to_stderr
  end
end
