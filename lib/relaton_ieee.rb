require "digest/md5"
require "yaml"
require "relaton_bib"
require "relaton_ieee/version"
require "relaton_ieee/ieee_bibliography"
require "relaton_ieee/hit_collection"
require "relaton_ieee/hit"
require "relaton_ieee/scrapper"
require "relaton_ieee/ieee_bibliographic_item"
require "relaton_ieee/committee"
require "relaton_ieee/xml_parser"
require "relaton_ieee/bibxml_parser"
require "relaton_ieee/hash_converter"
require "relaton_ieee/data_fetcher"

module RelatonIeee
  class Error < StandardError; end

  # Returns hash of XML reammar
  # @return [String]
  def self.grammar_hash
    gem_path = File.expand_path "..", __dir__
    grammars_path = File.join gem_path, "grammars", "*"
    grammars = Dir[grammars_path].sort.map { |gp| File.read gp }.join
    Digest::MD5.hexdigest grammars
  end
end
