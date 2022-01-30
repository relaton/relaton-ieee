RSpec.describe RelatonIeee::IeeeBibliography do
  it "raise RequestError is domain not reacheable" do
    expect(Faraday).to receive(:post).and_raise Faraday::ConnectionFailed.new("Connection error")
    expect do
      RelatonIeee::IeeeBibliography.search "ref"
    end.to raise_error RelatonBib::RequestError
  end
end
