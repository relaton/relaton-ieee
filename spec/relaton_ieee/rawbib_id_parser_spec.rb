RSpec.describe do
  # it do
  #   ids = {}
  #   File.readlines("spec/fixtures/normtitles.txt", encoding: "UTF-8").each do |nt|
  #     id = RelatonIeee::RawbibIdParser.parse(nt.strip)
  #     # expect(id).not_to be_nil
  #     # expect(ids[id]).to be_nil
  #     ids[id] ||= nt.strip if id
  #   end
  #   ids
  # end

  it do
    pid = RelatonIeee::RawbibIdParser.parse "IEEE Std 802.15.4j-2013 (Amendment to IEEE Std 802.15.4-2011 as amended by IEEE Std 802.15.4e-2012, IEEE Std 802.15.4f-2012, and IEEE Std 802.15.4g-2012)"
    id = pid.to_s
    id
  end
end
