RSpec.describe RelatonIeee::IeeeBibliography do
  it "raise RequestError is domain not reacheable" do
    expect(Relaton::Index).to receive(:find_or_create)
      .and_raise Faraday::ConnectionFailed.new("Connection error")
    expect do
      RelatonIeee::IeeeBibliography.search "ref"
    end.to raise_error RelatonBib::RequestError
  end
end
