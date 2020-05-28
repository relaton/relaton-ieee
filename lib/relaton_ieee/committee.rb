module RelatonIeee
  class Committee
    # @return [String]
    attr_reader :type, :name

    # @return [String, NilClass]
    attr_reader :chair

    # @param type [String]
    # @param name [String]
    # @param chair [String, NilClass]
    def initialize(type:, name:, chair: nil)
      @type = type
      @name = name
      @chair = chair
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.committee type: type do |b|
        b.name name
        b.chair chair if chair
      end
    end

    # @return [Hash]
    def to_hash
      hash = { type: type, name: name }
      hash["chair"] = chair if chair
      hash
    end
  end
end
