module RelatonIeee
  class IeeeBibliography
    class << self
      GH_URL = "https://raw.githubusercontent.com/relaton/relaton-data-ieee/main/data/".freeze

      #
      # Search IEEE bibliography item by reference.
      #
      # @param code [String]
      #
      # @return [RelatonIeee::IeeeBibliographicItem]
      #
      def search(code)
        ref = code.sub(/Std\s/i, "").gsub(/[\s,:\/]/, "_").squeeze("_").upcase
        url = "#{GH_URL}#{ref}.yaml"
        resp = Faraday.get url
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
        warn "[relaton-ieee] (\"#{code}\") fetching..."
        item = search(code)
        if item
          warn "[relaton-ieee] (\"#{code}\") found #{item.docidentifier.first.id}"
          item
        else
          warn "[relaton-ieee] (\"#{code}\") not found"
        end
      end
    end
  end
end
