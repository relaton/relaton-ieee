require "digest/md5"
require "faraday"
require "yaml"
require "relaton/index"
require "relaton/bib"
require_relative "ieee/version"
require_relative "ieee/util"
# require "relaton_ieee/document_type"
# require "relaton_ieee/document_status"
# require "relaton_ieee/ieee_bibliography"
require_relative "ieee/item"
require_relative "ieee/bibitem"
require_relative "ieee/bibdata"
# require "relaton_ieee/editorial_group"
# require "relaton_ieee/balloting_group"
# require "relaton_ieee/xml_parser"
# require "relaton_ieee/bibxml_parser"
# require "relaton_ieee/hash_converter"
# require "relaton_ieee/data_fetcher"

module Relaton
  module Ieee
    class Error < StandardError; end

    # Returns hash of XML reammar
    # @return [String]
    def self.grammar_hash
      # gem_path = File.expand_path "..", __dir__
      # grammars_path = File.join gem_path, "grammars", "*"
      # grammars = Dir[grammars_path].sort.map { |gp| File.read gp }.join
      Digest::MD5.hexdigest Relaton::Ieee::VERSION + Relaton::Bib::VERSION # grammars
    end
  end
end
