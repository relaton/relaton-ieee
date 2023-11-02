require "relaton/processor"

module RelatonIeee
  class Processor < Relaton::Processor
    attr_reader :idtype

    def initialize # rubocop:disable Lint/MissingSuper
      @short = :relaton_ieee
      @prefix = "IEEE"
      @defaultprefix = %r{^(?:(?:(?:ANSI|NACE)/)?IEEE|ANSI|AIEE|ASA|NACE|IRE)\s}
      @idtype = "IEEE"
      @datasets = %w[ieee-rawbib]
    end

    # @param code [String]
    # @param date [String, NilClass] year
    # @param opts [Hash]
    # @return [RelatonIeee::IeeeBibliographicItem]
    def get(code, date, opts)
      ::RelatonIeee::IeeeBibliography.get(code, date, opts)
    end

    #
    # Fetch all the documents from ./iee-rawbib directory
    #
    # @param [String] _source source name
    # @param [Hash] opts
    # @option opts [String] :output directory to output documents
    # @option opts [String] :format
    #
    def fetch_data(_source, opts)
      DataFetcher.fetch(**opts)
    end

    # @param xml [String]
    # @return [RelatonIeee::IeeeBibliographicItem]
    def from_xml(xml)
      ::RelatonIeee::XMLParser.from_xml xml
    end

    # @param hash [Hash]
    # @return [RelatonIeee::IeeeBibliographicItem]
    def hash_to_bib(hash)
      ::RelatonIeee::IeeeBibliographicItem.new(**hash)
    end

    # Returns hash of XML grammar
    # @return [String]
    def grammar_hash
      @grammar_hash ||= ::RelatonIeee.grammar_hash
    end

    #
    # Remove index file
    #
    def remove_index_file
      Relaton::Index.find_or_create(:ieee, url: true, file: IeeeBibliography::INDEX_FILE).remove_file
    end
  end
end
