module RelatonIeee
  class IeeeBibliography
    class << self
      GH_URL = "https://raw.githubusercontent.com/relaton/relaton-data-ieee/main/data/".freeze

      # @param code [String]
      # @return [RelatonIeee::HitCollection]
      def search(code)
        # HitCollection.new text
        ref = code.sub(/Std\s/i, "").gsub(/[\s,:\/]/, "_").squeeze("_").upcase
        url = "#{GH_URL}#{ref}.yaml"
        resp = Faraday.get url
        return unless resp.status == 200

        IeeeBibliographicItem.from_hash YAML.safe_load resp.body
      rescue Faraday::ConnectionFailed
        raise RelatonBib::RequestError, "Could not access #{GH_URL}"
      end

      # @param code [String] the IEEE standard Code to look up (e..g "528-2019")
      # @param year [String] the year the standard was published (optional)
      # @param opts [Hash] options
      #
      # @return [Hash, NilClass] returns { ret: RelatonBib::BibliographicItem }
      #   if document is found else returns NilClass
      def get(code, _year = nil, _opts = {}) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        warn "[relaton-ieee] (\"#{code}\") fetching..."
        item = search(code)
        # year ||= code.match(/(?<=-)\d{4}/)&.to_s
        # ret = bib_results_filter(result, code, year)
        if item # ret[:ret]
          # item = ret[:ret].fetch
          warn "[relaton-ieee] (\"#{code}\") found #{item.docidentifier.first.id}"
          item
        # else
        #   fetch_ref_err(code, year, ret[:years])
        end
      end

      private

      # Sort through the results from RelatonIeee, fetching them three at a time,
      # and return the first result that matches the code,
      # matches the year (if provided), and which # has a title (amendments do not).
      # Only expects the first page of results to be populated.
      # Does not match corrigenda etc (e.g. ISO 3166-1:2006/Cor 1:2007)
      # If no match, returns any years which caused mismatch, for error reporting
      #
      # @param result [RelatonIeee::HitCollection]
      # @param opts [Hash] options
      #
      # @return [Hash]
      # def bib_results_filter(result, ref, year) # rubocop:disable Metrics/AbcSize
      #   rp1 = ref_parts ref
      #   missed_years = []
      #   result.each do |hit|
      #     rp2 = ref_parts hit.hit[:ref]
      #     next if rp1[:code] != rp2[:code] || rp1[:corr] != rp2[:corr]

      #     return { ret: hit } if !year

      #     return { ret: hit } if year.to_i == hit.hit[:year]

      #     missed_years << hit.hit[:year]
      #   end
      #   { years: missed_years.uniq }
      # end

      # def ref_parts(ref)
      #   %r{
      #     ^(?:IEEE\s(?:Std\s)?)?
      #     (?<code>[^-/]+)
      #     (?:-(?<year>\d{4}))?
      #     (?:/(?<corr>\w+\s\d+-\d{4}))?
      #   }x.match ref
      # end

      # @param code [Strig]
      # @param year [String]
      # @param missed_years [Array<Strig>]
      # def fetch_ref_err(code, year, missed_years)
      #   id = year ? "#{code} year #{year}" : code
      #   warn "[relaton-ieee] WARNING: no match found online for #{id}. "\
      #     "The code must be exactly like it is on the standards website."
      #   unless missed_years.empty?
      #     warn "[relaton-ieee] (There was no match for #{year}, though there were matches "\
      #       "found for #{missed_years.join(', ')}.)"
      #   end
      #   nil
      # end
    end
  end
end
