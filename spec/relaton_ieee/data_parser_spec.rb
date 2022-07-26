RSpec.describe RelatonIeee::DataParser do
  let(:doc) do
    Nokogiri::XML <<~XML
      <publication>
        <publicationinfo>
          <standard_relationship type="V">1234</standard_relationship>
        </publicationinfo>
      </publication>
    XML
  end

  subject do
    df = RelatonIeee::DataFetcher.new "data", "yaml"
    df.instance_variable_get(:@backrefs)["1234"] = "IEEE 5678"
    RelatonIeee::DataParser.new doc.at("./publication"), df
  end

  context "parse date string" do
    it "year" do
      expect(subject.parse_date_string("1999")).to eq "1999"
    end

    it "with month name" do
      expect(subject.parse_date_string("1 May. 1994")).to eq "1994-05-01"
    end
  end

  context "create organization" do
    it "ANSI" do
      org = subject.create_org("ANSI")
      expect(org).to be_instance_of RelatonBib::Organization
      expect(org.abbreviation.content).to eq "ANSI"
      expect(org.name[0].content).to eq "American National Standards Institute"
      expect(org.url.to_s).to eq "https://www.ansi.org"
    end

    it "other" do
      org = subject.create_org("OORG")
      expect(org).to be_instance_of RelatonBib::Organization
      expect(org.name[0].content).to eq "OORG"
    end
  end

  it "parse relation" do
    rel = subject.parse_relation
    expect(rel).to be_instance_of RelatonBib::DocRelationCollection
    expect(rel.size).to eq 1
    expect(rel[0].type).to eq "updates"
    expect(rel[0].bibitem.formattedref.content).to eq "IEEE 5678"
  end

  context "parse abstract" do
    let(:doc) do
      Nokogiri::XML <<~XML
        <publication>
          <volume>
            <article>
              <articleinfo>
                <abstract abstracttype="Regular">Abstract</abstract>
                <abstract abstracttype="Standard">Abstract</abstract>
              </articleinfo>
            </article>
          </volume>
        </publication>
      XML
    end

    it do
      abs = subject.parse_abstract
      expect(abs).to be_instance_of Array
      expect(abs.size).to eq 1
      expect(abs[0].content).to eq "Abstract"
    end
  end

  context "parse title" do
    let(:doc) do
      Nokogiri::XML <<~XML
        <publication>
          <volume>
            <article>
              <title><![CDATA[Title - Redline]]></title>
            </article>
          </volume>
        </publication>
      XML
    end
    let(:title) { subject.parse_title }
    it { expect(title).to be_instance_of Array }
    it { expect(title.size).to eq 2 }
    it { expect(title[0]).to be_instance_of RelatonBib::TypedTitleString }
    it { expect(title[0].title.content).to eq "Title" }
    it { expect(title[1].title.content).to eq "Title - Redline" }
  end

  context "parse PubId" do
    let(:doc) do
      Nokogiri::XML <<~XML
        <publication>
          <normtitle><![CDATA[IEEE Std P802.5t/D2.5]]></normtitle>
          <publicationinfo>
            <isbn isbntype="New-2005" mediatype="Electronic">978-1-5044-3975-6</isbn>
          </publicationinfo>
          <volume>
            <article>
              <articleinfo>
                <articledoi>10.1109/IEEE.2012.624</articledoi>
              </articleinfo>
            </article>
          </volume>
        </publication>
      XML
    end

    let(:docids) { subject.parse_docid }
    it { expect(docids.size).to eq 4 }
    it { expect(docids[0].type).to eq "IEEE" }
    it { expect(docids[0].id).to eq "IEEE P802.5t/D-2.5" }
    it { expect(docids[0].primary).to be true }
    it { expect(docids[0].scope).to be_nil }
    it { expect(docids[1].type).to eq "IEEE" }
    it { expect(docids[1].id).to eq "IEEE P802.5t\u2122/D-2.5" }
    it { expect(docids[1].primary).to be true }
    it { expect(docids[1].scope).to eq "trademark" }
    it { expect(docids[2].type).to eq "ISBN" }
    it { expect(docids[2].id).to eq "978-1-5044-3975-6" }
    it { expect(docids[2].primary).to be_nil }
    it { expect(docids[2].scope).to be_nil }
    it { expect(docids[3].type).to eq "DOI" }
    it { expect(docids[3].id).to eq "10.1109/IEEE.2012.624" }
    it { expect(docids[3].primary).to be_nil }
    it { expect(docids[3].scope).to be_nil }
  end
end
