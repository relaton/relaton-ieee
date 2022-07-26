require "faraday"
require "relaton_ieee/hit"
require "fileutils"

module RelatonIeee
  class HitCollection < RelatonBib::HitCollection
    # DOMAIN = "https://standards.ieee.org".freeze
    GH_URL = "https://raw.githubusercontent.com/relaton/relaton-data-ieee/main/data/".freeze

    # @param reference [Strig]
    # @param opts [Hash]
    def initialize(reference) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      super
      ref = reference.gsub(/[\s,:\/]/, "_").squeeze("_").upcase
      url = "#{GH_URL}#{ref}.yaml"
      resp = Faraday.get url
      hit = YAML.load resp.body
      # code1 = reference.sub(/^IEEE\s(Std\s)?/, "")
      # url = "#{DOMAIN}/wp-admin/admin-ajax.php"
      # query = reference.gsub("/", " ")
      # resp = Faraday.post url, { action: "ieee_cloudsearch", q: query }
      # json = JSON.parse resp.body
      # unless json["results"]
      #   @array = []
      #   return
      # end

      # @array = json["results"]["hits"]["hit"].reduce([]) do |s, hit|
      #   flds = hit["fields"]
      #   /^(?:\w+\s)?(?<code2>[A-Z\d.]+)(?:-(?<year>\d{4}))?/ =~ flds["meta_designation_l"]
      #   next s unless code2 && code1 =~ %r{^#{code2}}

      #   hit_data = {
      #     ref: flds["meta_designation_l"],
      #     year: year.to_i,
      #     url: flds["doc_id_l"],
      #   }
      #   s << Hit.new(hit_data, self)
      # end.sort_by { |h| h.hit[:year].to_s + h.hit[:url] }.reverse
    end
  end
end
