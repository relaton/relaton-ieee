describe RelatonIeee::DocumentStatus do
  it "warn when stage is invalid" do
    expect do
      described_class::Stage.new value: "invalid"
    end.to output("[relaton-ieee] Stage value must be one of developing, active, inactive\n").to_stderr
  end
end
