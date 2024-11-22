# RSpec.describe RelatonIeee::DataParser do
#   let(:doc) do
#     Nokogiri::XML <<~XML
#       <publication>
#         <publicationinfo>
#           <standard_relationship type="V">1234</standard_relationship>
#         </publicationinfo>
#       </publication>
#     XML
#   end

#   subject do
#     df = RelatonIeee::DataFetcher.new "data", "yaml"
#     df.instance_variable_get(:@backrefs)["1234"] = "IEEE 5678"
#     RelatonIeee::DataParser.new doc.at("./publication"), df
#   end

#   it "parse" do
#     expect(subject).to receive(:docnumber).and_return "1234"
#     expect(subject).to receive(:parse_title).and_return :title
#     expect(subject).to receive(:parse_date).and_return :date
#     expect(subject).to receive(:parse_docid).and_return :docid
#     expect(subject).to receive(:parse_contributor).and_return :contributor
#     expect(subject).to receive(:parse_abstract).and_return :abstract
#     expect(subject).to receive(:parse_copyright).and_return :copyright
#     expect(subject).to receive(:parse_docstatus).and_return :status
#     expect(subject).to receive(:parse_relation).and_return :relation
#     expect(subject).to receive(:parse_link).and_return :link
#     expect(subject).to receive(:parse_keyword).and_return :keyword
#     expect(subject).to receive(:parse_ics).and_return :ics
#     expect(subject).to receive(:parse_editorialgroup).and_return :editorialgroup
#     expect(subject).to receive(:parse_standard_status).and_return :standard_status
#     expect(subject).to receive(:parse_standard_modified).and_return :standard_modified
#     expect(subject).to receive(:parse_pubstatus).and_return :pubstatus
#     expect(subject).to receive(:parse_holdstatus).and_return :holdstatus
#     expect(subject).to receive(:parse_doctype).and_return :doctype
#     args = {
#       type: "standard",
#       docnumber: "1234",
#       title: :title,
#       date: :date,
#       docid: :docid,
#       contributor: :contributor,
#       abstract: :abstract,
#       copyright: :copyright,
#       language: ["en"],
#       script: ["Latn"],
#       docstatus: :status,
#       relation: :relation,
#       link: :link,
#       keyword: :keyword,
#       ics: :ics,
#       editorialgroup: :editorialgroup,
#       standard_status: :standard_status,
#       standard_modified: :standard_modified,
#       pubstatus: :pubstatus,
#       holdstatus: :holdstatus,
#       doctype: :doctype,
#     }
#     expect(RelatonIeee::IeeeBibliographicItem).to receive(:new).with(args).and_return :item
#     expect(subject.parse).to eq :item
#   end

#   context "parse_date" do
#     let(:doc) do
#       Nokogiri::XML <<~XML
#         <publication>
#           <volume>
#             <article>
#               <articleinfo>
#                 <date>
#                   <year>1999</year>
#                   <month>31 May.</month>
#                 </date>
#               </articleinfo>
#             </article>
#           </volume>
#         </publication>
#       XML
#     end

#     it "with day in month" do
#       date = subject.parse_date
#       expect(date[0].on).to eq "1999-05-31"
#     end
#   end

#   context "parse date string" do
#     it "year" do
#       expect(subject.parse_date_string("1999")).to eq "1999"
#     end

#     it "with month name" do
#       expect(subject.parse_date_string("1 May. 1994")).to eq "1994-05-01"
#     end
#   end

#   context "parse contributor" do
#     let(:doc) do
#       Nokogiri::XML <<~XML
#         <publication>
#           <publicationinfo>
#             <publisher>
#               <publishername>IEEE</publishername>
#               <address>
#                 <country>USA</country>
#               </address>
#             </publisher>
#           </publicationinfo>
#         </publication>
#       XML
#     end

#     it "don't parse address without city" do
#       contrib = subject.parse_contributor
#       expect(contrib[0].entity.contact.size).to eq 0
#     end
#   end

#   context "parse country city" do
#     it "without city" do
#       doc = Nokogiri::XML <<~XML
#         <address>
#           <country>USA</country>
#         </address>
#       XML
#       addr = doc.at "/address"
#       expect(subject.parse_country_city(addr)).to be_nil
#     end

#     it "with city, state, and country" do
#       doc = Nokogiri::XML <<~XML
#         <address>
#           <city>City, State</city>
#           <country>Country</country>
#         </address>
#       XML
#       addr = doc.at "/address"
#       expect(subject.parse_country_city(addr)).to eq ["City", "Country", "State"]
#     end

#     it "use USA as default country" do
#       doc = Nokogiri::XML <<~XML
#         <address>
#           <city>City</city>
#         </address>
#       XML
#       addr = doc.at "/address"
#       expect(subject.parse_country_city(addr)).to eq ["City", "USA", nil]
#     end
#   end

#   context "create organization" do
#     it "ANSI" do
#       org = subject.create_org("ANSI")
#       expect(org).to be_instance_of RelatonBib::Organization
#       expect(org.abbreviation.content).to eq "ANSI"
#       expect(org.name[0].content).to eq "American National Standards Institute"
#       expect(org.url.to_s).to eq "https://www.ansi.org"
#     end

#     it "other" do
#       org = subject.create_org("OORG")
#       expect(org).to be_instance_of RelatonBib::Organization
#       expect(org.name[0].content).to eq "OORG"
#     end
#   end

#   it "parse relation" do
#     rel = subject.parse_relation
#     expect(rel).to be_instance_of RelatonBib::DocRelationCollection
#     expect(rel.size).to eq 1
#     expect(rel[0].type).to eq "updates"
#     expect(rel[0].bibitem.formattedref.content).to eq "IEEE 5678"
#   end

#   context "parse abstract" do
#     let(:doc) do
#       Nokogiri::XML <<~XML
#         <publication>
#           <volume>
#             <article>
#               <articleinfo>
#                 <abstract abstracttype="Regular">Abstract</abstract>
#                 <abstract abstracttype="Standard">Abstract</abstract>
#               </articleinfo>
#             </article>
#           </volume>
#         </publication>
#       XML
#     end

#     it do
#       abs = subject.parse_abstract
#       expect(abs).to be_instance_of Array
#       expect(abs.size).to eq 1
#       expect(abs[0].content).to eq "Abstract"
#     end
#   end

#   context "parse title" do
#     let(:doc) do
#       Nokogiri::XML <<~XML
#         <publication>
#           <volume>
#             <article>
#               <title><![CDATA[Title &#8212; Redline]]></title>
#             </article>
#           </volume>
#         </publication>
#       XML
#     end
#     let(:title) { subject.parse_title }
#     it { expect(title).to be_instance_of Array }
#     it { expect(title.size).to eq 2 }
#     it { expect(title[0]).to be_instance_of RelatonBib::TypedTitleString }
#     it { expect(title[0].title.content).to eq "Title" }
#     it { expect(title[1].title.content).to eq "Title \u2014 Redline" }
#   end

#   context "parse PubId" do
#     let(:doc) do
#       Nokogiri::XML <<~XML
#         <publication>
#           <normtitle><![CDATA[IEEE Std P802.5t/D2.5]]></normtitle>
#           <publicationinfo>
#             <isbn isbntype="New-2005" mediatype="Electronic">978-1-5044-3975-6</isbn>
#           </publicationinfo>
#           <volume>
#             <article>
#               <articleinfo>
#                 <articledoi>10.1109/IEEE.2012.624</articledoi>
#               </articleinfo>
#             </article>
#           </volume>
#         </publication>
#       XML
#     end

#     let(:docids) { subject.parse_docid }
#     it { expect(docids.size).to eq 4 }
#     it { expect(docids[0].type).to eq "IEEE" }
#     it { expect(docids[0].id).to eq "IEEE P802.5t/D-2.5" }
#     it { expect(docids[0].primary).to be true }
#     it { expect(docids[0].scope).to be_nil }
#     it { expect(docids[1].type).to eq "IEEE" }
#     it { expect(docids[1].id).to eq "IEEE P802.5t\u2122/D-2.5" }
#     it { expect(docids[1].primary).to be true }
#     it { expect(docids[1].scope).to eq "trademark" }
#     it { expect(docids[2].type).to eq "ISBN" }
#     it { expect(docids[2].id).to eq "978-1-5044-3975-6" }
#     it { expect(docids[2].primary).to be_nil }
#     it { expect(docids[2].scope).to be_nil }
#     it { expect(docids[3].type).to eq "DOI" }
#     it { expect(docids[3].id).to eq "10.1109/IEEE.2012.624" }
#     it { expect(docids[3].primary).to be_nil }
#     it { expect(docids[3].scope).to be_nil }
#   end

#   context "parse committee" do
#     let(:doc) do
#       Nokogiri::XML <<~XML
#         <publication>
#           <publicationinfo>
#             <pubsponsoringcommitteeset>
#               <pubsponsoringcommittee>Committee</pubsponsoringcommittee>
#             </pubsponsoringcommitteeset>
#           </publicationinfo>
#         </publication>
#       XML
#     end
#     it { expect(subject.parse_editorialgroup).to be_instance_of RelatonIeee::EditorialGroup }
#     it { expect(subject.parse_editorialgroup.committee).to eq ["Committee"] }
#   end

#   context "parse docstatus" do
#     it "not present" do
#       expect(subject.parse_docstatus).to be_nil
#     end

#     it "active" do
#       doc = Nokogiri::XML <<~XML
#         <publication>
#           <publicationinfo>
#             <standardmodifierset>
#               <standard_modifier>Approved</standard_modifier>
#             </standardmodifierset>
#           </publicationinfo>
#         </publication>
#       XML
#       subject.instance_variable_set(:@doc, doc.at("/publication"))
#       docstatus = subject.parse_docstatus
#       expect(docstatus).to be_instance_of RelatonIeee::DocumentStatus
#       expect(docstatus.stage.value).to eq "approved"
#     end

#     it "other" do
#       doc = Nokogiri::XML <<~XML
#         <publication>
#           <publicationinfo>
#             <standardmodifierset>
#               <standard_status>Other</standard_status>
#             </standardmodifierset>
#           </publicationinfo>
#         </publication>
#       XML
#       subject.instance_variable_set(:@doc, doc.at("/publication"))
#       docstatus = subject.parse_docstatus
#       expect(docstatus).to be_nil
#     end
#   end

#   it "parse document" do
#     source = "spec/fixtures/rawbib/cache/IEEEDraftStd/1998/4039943/4039944/04039945.xml"
#     doc = Nokogiri::XML File.read(source, encoding: "UTF-8")
#     publication = doc.at "/publication"
#     subject.instance_variable_set(:@doc, publication)
#     bib = subject.parse
#     xml = bib.to_xml bibdata: true
#     output = "spec/fixtures/ieee-std.xml"
#     File.write output, xml, encoding: "UTF-8" unless File.exist? output
#     expect(xml).to be_equivalent_to File.read(output, encoding: "UTF-8")
#       .gsub(%r{(?<=<fetched>)\d{4}-\d{2}-\d{2}}, Date.today.to_s)
#     schema = Jing.new "grammars/relaton-ieee-compile.rng"
#     errors = schema.validate output
#     expect(errors).to eq []
#   end
# end
