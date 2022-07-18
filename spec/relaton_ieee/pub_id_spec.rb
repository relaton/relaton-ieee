describe RelatonIeee::PubId do
  context "Instance methods" do
    let(:pubid) { { number: "802.11", publisher: "IEEE", year: "2007" } }
    subject { described_class.new(pubid) }

    context "to_s" do
      it "without trademark" do
        expect(subject.to_s).to eq "IEEE 802.11-2007"
      end

      context "with trademark" do
        shared_examples "render string" do |pubid, expected|
          subject { described_class.new(pubid) }

          it { expect(subject.to_s(trademark: true)).to eq expected }
        end

        it_behaves_like "render string", { number: "802.11", publisher: "IEEE", year: "2007" }, "IEEE 802.11\u00AE-2007"
        it_behaves_like "render string", { number: "2030", publisher: "IEEE", year: "2011" }, "IEEE 2030\u00AE-2011"
        it_behaves_like "render string", { number: "1619", publisher: "IEEE", year: "2007" }, "IEEE 1619\u2122-2007"
      end
    end

    context "to_id" do
      it "single id" do
        expect(subject.to_id).to eq "IEEE 802.11-2007"
      end

      context "multiple ids" do
        let(:pubid) do
          [ { number: "960", publisher: "IEEE" }, { number: "1177", year: "1989" } ]
        end

        it { expect(subject.to_id).to eq "IEEE 960-1989" }
      end
    end
  end
end
