shared_examples "create identifier with license" do |ref, tm|
  subject { described_class.send(:fetch_docid, ref) }
  it { expect(subject).to be_instance_of Array }
  it { expect(subject[1]).to be_instance_of RelatonBib::DocumentIdentifier }
  it { expect(subject[1].id).to match(/IEEE\s(Std\s)?[.\w]+#{tm}/) }
  it { expect(subject[1].type).to eq "IEEE" }
  it { expect(subject[1].scope).to eq "trademark" }
  it { expect(subject[1].primary).to be true }
end

describe RelatonIeee::Scrapper do
  it_behaves_like "create identifier with license", "IEEE Std 802.11", "\u00AE"
  it_behaves_like "create identifier with license", "IEEE 802.11", "\u00AE"
  it_behaves_like "create identifier with license", "IEEE Std 2030.2-2015", "\u00AE"
  it_behaves_like "create identifier with license", "IEEE 2030.2-2015", "\u00AE"
  it_behaves_like "create identifier with license", "IEEE Std 528-2019", "\u2122"
end
