module RelatonIeee
  class IeeeBibliography
    class << self
      # @param text [String]
      # @return [RelatonIeee::HitCollection]
      def search(text)
        HitCollection.new text
      rescue Faraday::ConnectionFailed
        raise RelatonBib::RequestError, "Could not access #{HitCollection::DOMAIN}"
      end

      # @param code [String] the IEEE standard Code to look up (e..g "528-2019")
      # @param year [String] the year the standard was published (optional)
      # @param opts [Hash] options
      #
      # @return [Hash, NilClass] returns { ret: RelatonBib::BibliographicItem }
      #   if document is found else returns NilClass
      def get(code, year = nil, _opts = {})
        warn "[relaton-ieee] (\"#{code}\") fetching..."
        result = search(code) || (return nil)
        year ||= code.match(/(?<=-)\d{4}/)&.to_s
        ret = bib_results_filter(result, year)
        if ret[:ret]
          item = ret[:ret].fetch
          warn "[relaton-ieee] (\"#{code}\") found #{item.docidentifier.first.id}"
          item
        else
          fetch_ref_err(code, year, ret[:years])
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
      def bib_results_filter(result, year)
        missed_years = []
        result.each do |hit|
          return { ret: hit } if !year

          return { ret: hit } if year.to_i == hit.hit[:year]

          missed_years << hit.hit[:year]
        end
        { years: missed_years.uniq }
      end

      # @param code [Strig]
      # @param year [String]
      # @param missed_years [Array<Strig>]
      def fetch_ref_err(code, year, missed_years)
        id = year ? "#{code} year #{year}" : code
        warn "[relaton-ieee] WARNING: no match found online for #{id}. "\
          "The code must be exactly like it is on the standards website."
        unless missed_years.empty?
          warn "[relaton-ieee] (There was no match for #{year}, though there were matches "\
            "found for #{missed_years.join(', ')}.)"
        end
        nil
      end
    end
  end
end
