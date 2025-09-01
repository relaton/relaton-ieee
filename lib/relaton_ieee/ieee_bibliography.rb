module RelatonIeee
  class IeeeBibliography
    GH_URL = "https://raw.githubusercontent.com/relaton/relaton-data-ieee/main/".freeze
    INDEX_FILE = "index-v1.yaml".freeze

    class << self
      #
      # Search IEEE bibliography item by reference.
      #
      # @param code [String]
      #
      # @return [RelatonIeee::IeeeBibliographicItem]
      #
      def search(code) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        # ref = code.sub(/Std\s/i, "") # .gsub(/[\s,:\/]/, "_").squeeze("_").upcase
        index = Relaton::Index.find_or_create :ieee, url: "#{GH_URL}index-v1.zip", file: INDEX_FILE
        row = index.search(code).min_by { |r| r[:id] }
        return unless row

        resp = Faraday.get "#{GH_URL}#{row[:file]}"
        return unless resp.status == 200

        hash = YAML.safe_load resp.body
        hash["fetched"] = Date.today.to_s
        IeeeBibliographicItem.from_hash hash
      rescue Faraday::ConnectionFailed
        raise RelatonBib::RequestError, "Could not access #{GH_URL}"
      end

      #
      # Get IEEE bibliography item by reference.
      #
      # @param code [String] the IEEE standard Code to look up (e..g "528-2019")
      # @param year [String] the year the standard was published (optional)
      # @param opts [Hash] options
      #
      # @return [Hash, NilClass] returns { ret: RelatonBib::BibliographicItem }
      #   if document is found else returns NilClass
      #
      def get(code, _year = nil, _opts = {}) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        Util.info "Fetching from Relaton repository ...", key: code
        item = search(code)
        if item
          Util.info "Found: `#{item.docidentifier.first.id}`", key: code
          item
        else
          Util.info "Not found.", key: code
          nil
        end
      end
    end
  end
end
