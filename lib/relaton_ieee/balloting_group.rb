module RelatonIeee
  class BallotingGroup
    TYPES = %w[individual entity].freeze

    # @return [String]
    attr_reader :type, :content

    #
    # Initialize balloting group
    #
    # @param [String] type type
    # @param [String] content content
    #
    def initialize(type:, content:)
      unless TYPES.include?(type)
        Util.warn "type of Balloting group must be one of `#{TYPES.join('`, `')}`"
      end

      @type = type
      @content = content
    end

    #
    # Render balloting group to XML
    #
    # @param [Nokogiri::XML::Builder] builder XML builder
    #
    def to_xml(builder)
      builder.send :"balloting-group", content, type: type
    end

    #
    # Render balloting group to Hash
    #
    # @return [Hash] balloting group as Hash
    #
    def to_hash
      { "type" => type, "content" => content }
    end

    #
    # Render balloting group to AsciiBib
    #
    # @param [String] prefix Prefix
    #
    # @return [String] AsciiBib
    #
    def to_asciibib(prefix = "")
      pref = prefix.empty? ? prefix : "#{prefix}."
      pref += "balloting-group"
      out = "#{pref}.type:: #{type}\n"
      out += "#{pref}.content:: #{content}\n"
      out
    end
  end
end
