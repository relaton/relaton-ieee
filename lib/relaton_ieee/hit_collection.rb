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

    # @param ref [Strig]
    # @param opts [Hash]
    def initialize(ref) # rubocop:disable Metrics/MethodLength
      super
      code = ref.sub /^IEEE\s/, ""
      search = CGI.escape({ data: { searchTerm: code } }.to_json)
      url = "#{DOMAIN}/bin/standards/search?data=#{search}"
      resp = Faraday.get url
      resp_json = JSON.parse resp.body
      json = JSON.parse resp_json["message"]
      @array = json["response"]["searchResults"]["resultsMapList"]
        .reduce([]) do |s, hit|
          /^(?:\w+\s)?(?<id>[^-\/]+)(-(?<year>\d{4}))?/ =~ hit["record"]["recordTitle"]
          next s unless id && code =~ %r{^#{id}}

          s << Hit.new(hit["record"].merge(code: id, year: year.to_i), self)
        end.sort_by { |h| h.hit[:year].to_s + h.hit["recordURL"] }.reverse
    end
    # rubocop:enable Metrics/AbcSize
  end
end
