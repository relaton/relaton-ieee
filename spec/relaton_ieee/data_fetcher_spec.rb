RSpec.describe RelatonIeee::DataFetcher do
  it "fetch data" do
    expect(FileUtils).to receive(:mkdir_p).with("data")
    files = Dir["spec/fixtures/rawbib/**/*.{xml,zip}"]
    expect(Dir).to receive(:[]).with("ieee-rawbib/**/*.{xml,zip}").and_return files
    expect(File).to receive(:write).with("data/IEEE_P802.22_D-3.0-2011-03.yaml", kind_of(String), encoding: "UTF-8")
    RelatonIeee::DataFetcher.fetch
  end

  context "instance" do
    let(:df) { RelatonIeee::DataFetcher.new "data", "yaml" }

    it "warn if error" do
      files = Dir["spec/fixtures/rawbib/**/*.{xml,zip}"]
      expect(Dir).to receive(:[]).with("ieee-rawbib/**/*.{xml,zip}").and_return files
      expect(df).to receive(:fetch_doc).and_raise(StandardError).twice
      expect { df.fetch }.to output(/File: spec\/fixtures\/rawbib/).to_stderr_from_any_process
    end

    it "handle empty file" do
      expect do
        expect(df.fetch_doc("", "file.xml")).to be_nil
      end.to output(/WARN: Empty file: `file\.xml`/).to_stderr_from_any_process
    end

    it "create relation" do
      rel = df.create_relation "V", "AIEE 15.1928-05"
      expect(rel).to be_a RelatonBib::DocumentRelation
      expect(rel.type).to eq "updates"
      expect(rel.description.content).to eq "revises"
      expect(rel.bibitem).to be_instance_of RelatonIeee::IeeeBibliographicItem
      expect(rel.bibitem.docidentifier[0].id).to eq "AIEE 15.1928-05"
      expect(rel.bibitem.docidentifier[0].type).to eq "IEEE"
      expect(rel.bibitem.docidentifier[0].primary).to be true
      expect(rel.bibitem.formattedref.content).to eq "AIEE 15.1928-05"
    end

    context "when ouput file exists" do
      let(:bib) do
        docid = RelatonBib::DocumentIdentifier.new id: "IEEE 5678", primary: true
        title = [{ content: "Title" }]
        RelatonIeee::IeeeBibliographicItem.new docnumber: "5678", title: title, docid: [docid]
      end

      before(:each) do
        parser = double "parser"
        expect(RelatonIeee::IdamsParser).to receive(:new).and_return parser
        expect(parser).to receive(:parse).and_return bib
        df.instance_variable_get(:@backrefs)["4321"] = "IEEE 5678"
      end

      it "warn" do
        doc = <<~XML
          <publication>
            <title>Title</title>
            <publicationinfo>
              <amsid>1234</amsid>
              <standard_id>4321</standard_id>
              <stdnumber>5677</stdnumber>
            </publicationinfo>
          </publication>
        XML
        bib.instance_variable_set :@docnumber, "3412"
        expect { df.fetch_doc(doc, "file.xml") }.to output(
          /WARN: Document exists ID: `IEEE 5678` AMSID: `1234` source: `file\.xml`\. Other AMSID: `4321`/,
        ).to_stderr_from_any_process
      end

      it "rewrite file if PubID includes a docnumber" do
        doc = <<~XML
          <publication>
            <title>IEEE 5678 Title</title>
            <publicationinfo>
              <amsid>1234</amsid>
              <standard_id>4321</standard_id>
              <stdnumber>5678</stdnumber>
            </publicationinfo>
          </publication>
        XML
        expect(File).to receive(:write).with("data/5678.yaml", kind_of(String), encoding: "UTF-8")
        expect { df.fetch_doc(doc, "file.xml") }.to output(
          /WARN: Document exists ID: `IEEE 5678` AMSID: `1234` source: `file\.xml`\. Other AMSID: `4321`/,
        ).to_stderr_from_any_process
      end
    end

    context "hamdle relations" do
      before(:each) do
        df.instance_variable_get(:@crossrefs)["5678"] = [{ amsid: "3412", type: "V" }]
      end

      it "add cross-reference to existed PubID" do
        amsid = double "amsid", date_string: "1234", type: "C"
        df.add_crossref "5678", amsid
        expect(df.instance_variable_get(:@crossrefs)["5678"]).to eq [
          { amsid: "3412", type: "V" }, { amsid: "1234", type: "C" }
        ]
      end

      it "udate unresolved relations" do
        df.instance_variable_get(:@backrefs)["3412"] = "7809"
        docid = RelatonBib::DocumentIdentifier.new id: "5678"
        title = [{ content: "Title" }]
        bib = RelatonIeee::IeeeBibliographicItem.new title: title, docid: [docid]
        expect(df).to receive(:read_bib).with("5678").and_return bib
        expect(df).to receive(:save_doc) do |arg|
          expect(arg.relation[0].type).to eq "updates"
          expect(arg.relation[0].description.content).to eq "revises"
          expect(arg.relation[0].bibitem.formattedref.content).to eq "7809"
        end
        df.update_relations
      end
    end

    context "read saved document" do
      it "in YAML format" do
        yaml = {
          "title" => {
            "content" => "Title",
            "type" => "main",
            "language" => "en",
            "script" => "Latn",
            "format" => "text/plain",
          },
          "docid" => { "id" => "5678", "type" => "IEEE" },
        }.to_yaml
        expect(File).to receive(:read).with("data/5678.yaml", encoding: "UTF-8").and_return yaml
        expect(df.read_bib("5678")).to be_instance_of RelatonIeee::IeeeBibliographicItem
      end

      it "in XML format" do
        xml = <<~XML
          <bibitem>
            <title type="main" format="text/plain" language="en" script="Latn">Title</title>
            <docidentifier type="IEEE">5678</docidentifier>
          </bibitem>
        XML
        df.instance_variable_set :@format, "xml"
        df.instance_variable_set :@ext, "xml"
        expect(File).to receive(:read).with("data/5678.xml", encoding: "UTF-8").and_return xml
        expect(df.read_bib("5678")).to be_instance_of RelatonIeee::IeeeBibliographicItem
      end

      it "in BibXML format" do
        xml = <<~XML
          <reference anchor="IEEEStdP802.11ma/D3.0">
            <front>
              <title>Title</title>
            </front>
          </reference>
        XML
        df.instance_variable_set :@format, "bibxml"
        df.instance_variable_set :@ext, "xml"
        expect(File).to receive(:read).with("data/5678.xml", encoding: "UTF-8").and_return xml
        expect(df.read_bib("5678")).to be_instance_of RelatonIeee::IeeeBibliographicItem
      end
    end

    it "return nil and warn if docnumber is nil" do
      xml = <<~XML
        <publication>
          <normtitle>Title</normtitle>
        </publication>
      XML
      bib = double "bib", docnumber: nil
      dp = double "dp", parse: bib
      expect(RelatonIeee::IdamsParser).to receive(:new).with(kind_of(Ieee::Idams::PubModel), df).and_return dp
      expect do
        expect(df.fetch_doc(xml, "filename")).to be_nil
      end.to output(
        "[relaton-ieee] WARN: PubID parse error. Normtitle: `Title`, file: `filename`\n"
      ).to_stderr_from_any_process
    end

    context "save document" do
      let(:bib) { double "bib", docnumber: "5678" }

      it "in XML format" do
        df.instance_variable_set :@format, "xml"
        df.instance_variable_set :@ext, "xml"
        expect(bib).to receive(:to_xml).with(bibdata: true).and_return "<xml/>"
        expect(File).to receive(:write).with("data/5678.xml", "<xml/>", encoding: "UTF-8")
        df.save_doc bib
      end

      it "in YAML format" do
        expect(bib).to receive(:to_hash).and_return({ "title" => "Title" })
        expect(File).to receive(:write).with("data/5678.yaml", { "title" => "Title" }.to_yaml, encoding: "UTF-8")
        df.save_doc bib
      end

      it "in BibXML format" do
        df.instance_variable_set :@format, "bibxml"
        df.instance_variable_set :@ext, "xml"
        expect(bib).to receive(:to_bibxml).and_return "<bibxml/>"
        expect(File).to receive(:write).with("data/5678.xml", "<bibxml/>", encoding: "UTF-8")
        df.save_doc bib
      end
    end
  end

  # it do
  #   RelatonIeee::DataFetcher.fetch
  # end
end
