shared_examples "create identifier with license" do |ref|
  subject { described_class.send(:fetch_docid, ref) }
  it { expect(subject).to be_instance_of Array }
  it { expect(subject.first).to be_instance_of RelatonBib::DocumentIdentifier }
  it { expect(subject.first.id).to eq ref }
  it { expect(subject.first.type).to eq "IEEE" }
  it { expect(subject.first.scope).to eq "trademark" }
  it { expect(subject.first.primary).to be true }
end

describe RelatonIeee::Scrapper do
  it_behaves_like "create identifier with license", "IEEE Std 802.11"
  it_behaves_like "create identifier with license", "IEEE 802.11"
  it_behaves_like "create identifier with license", "IEEE Std 2030.2-2015"
  it_behaves_like "create identifier with license", "IEEE 2030.2-2015"
end
