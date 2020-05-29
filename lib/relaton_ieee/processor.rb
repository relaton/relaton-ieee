require "relaton/processor"

module RelatonIeee
  class Processor < Relaton::Processor
    attr_reader :idtype

    def initialize
      @short = :relaton_ieee
      @prefix = "IEEE"
      @defaultprefix = %r{^IEEE\s}
      @idtype = "IEEE"
    end

    # @param code [String]
    # @param date [String, NilClass] year
    # @param opts [Hash]
    # @return [RelatonIeee::IeeeBibliographicItem]
    def get(code, date, opts)
      ::RelatonIeee::IeeeBibliography.get(code, date, opts)
    end

    # @param xml [String]
    # @return [RelatonIeee::IeeeBibliographicItem]
    def from_xml(xml)
      ::RelatonIeee::XMLParser.from_xml xml
    end

    # @param hash [Hash]
    # @return [RelatonIeee::IeeeBibliographicItem]
    def hash_to_bib(hash)
      item_hash = ::RelatonIeee::HashConverter.hash_to_bib(hash)
      ::RelatonIeee::IeeeBibliographicItem.new item_hash
    end

    # Returns hash of XML grammar
    # @return [String]
    def grammar_hash
      @grammar_hash ||= ::RelatonIeee.grammar_hash
    end
  end
end
