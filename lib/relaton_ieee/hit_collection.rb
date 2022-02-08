require "faraday"
require "relaton_ieee/hit"
require "fileutils"

module RelatonIeee
  class HitCollection < RelatonBib::HitCollection
    DOMAIN = "https://standards.ieee.org".freeze
    DATADIR = File.expand_path ".relaton/ogc/", Dir.home
    DATAFILE = File.expand_path "bibliography.json", DATADIR
    ETAGFILE = File.expand_path "etag.txt", DATADIR

    # rubocop:disable Metrics/AbcSize

    # @param reference [Strig]
    # @param opts [Hash]
    def initialize(reference) # rubocop:disable Metrics/MethodLength
      super
      code1 = reference.sub(/^IEEE\s(Std\s)?/, "")
      url = "#{DOMAIN}/wp-admin/admin-ajax.php"
      query = reference.gsub("/", " ")
      resp = Faraday.post url, { action: "ieee_cloudsearch", q: query }
      json = JSON.parse resp.body
      html = Nokogiri::HTML json["html"]
      @array = html.xpath("//h4/a").reduce([]) do |s, hit|
        ref = hit.text.strip
        /^(?:\w+\s)?(?<code2>[A-Z\d.]+)(?:-(?<year>\d{4}))?/ =~ ref
        next s unless code2 && code1 =~ %r{^#{code2}}

        hit_data = { ref: ref, year: year.to_i, url: hit[:href] }
        s << Hit.new(hit_data, self)
      end.sort_by { |h| h.hit[:year].to_s + h.hit[:url] }.reverse
    end
    # rubocop:enable Metrics/AbcSize
  end
end
