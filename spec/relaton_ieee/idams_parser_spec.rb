describe RelatonIeee::IdamsParser do
  context "parse" do
    let(:doc) { Ieee::Idams::Publication.from_xml source_xml }
    let(:fetcher) { RelatonIeee::DataFetcher.new "data", "xml" }
    subject { described_class.new doc, fetcher }
    let(:bibitem) { subject.parse }

    shared_examples "parse file" do |file|
      let(:source_xml) { File.read "spec/fixtures/examples/#{file}.xml" }
      let(:output_file) { "spec/fixtures/#{file}.xml" }
      let(:xml) { bibitem.to_xml bibdata: true }

      it do
        expect(bibitem).to be_instance_of RelatonIeee::IeeeBibliographicItem
        File.write output_file, xml, encoding: "UTF-8" unless File.exist? output_file
        expect(xml).to be_equivalent_to File.read(output_file, encoding: "UTF-8")
          .gsub(/(?<=<fetched>)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
      end
    end

    it_behaves_like "parse file", "08684487"
    it_behaves_like "parse file", "07873195"
    it_behaves_like "parse file", "04152543"
    it_behaves_like "parse file", "05200238"
    it_behaves_like "parse file", "05491847"
    it_behaves_like "parse file", "04140777"
    it_behaves_like "parse file", "00026466"
    it_behaves_like "parse file", "07409855"

    context "backrefs" do
      let(:source_xml) { File.read "spec/fixtures/examples/07873195.xml" }
      let(:xml) { bibitem.to_xml bibdata: true }
      let(:output_file) { "spec/fixtures/baclref_relation.xml" }
      before { fetcher.instance_variable_get(:@backrefs)["2487"] = "IEEE P650" }

      it do
        File.write output_file, xml, encoding: "UTF-8" unless File.exist? output_file
        expect(xml).to be_equivalent_to File.read(output_file, encoding: "UTF-8")
      end
    end
  end
end
