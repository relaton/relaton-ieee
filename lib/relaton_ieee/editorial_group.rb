module RelatonIeee
  class EditorialGroup
    # @return [String]
    attr_reader :society, :working_group
    # @return [RelatonIeee::BallotingGroup] Balloting group
    attr_reader :balloting_group
    # @return [Array<String>] Committee
    attr_reader :committee

    #
    # Initialize editorial group
    #
    # @param [Hash] **args Hash of arguments
    # @option args [String] :society Society
    # @option args [RelatonIeee::BallotingGroup, Hash] :balloting_group Balloting group
    # @option args [String] :working_group Working group
    # @option args [Array<String>] :committee Committee
    #
    def initialize(**args)
      unless args[:committee].is_a?(Array) && args[:committee].any?
        raise ArgumentError, ":committee is required"
      end

      @society = args[:society]
      @balloting_group = if args[:balloting_group].is_a?(Hash)
                           BallotingGroup.new(**args[:balloting_group])
                         else args[:balloting_group]
                         end
      @working_group = args[:working_group]
      @committee = args[:committee]
    end

    def presence?
      true
    end

    #
    # Render editorial group to XML
    #
    # @param [Nokogiri::XML::Builder] builder XML builder
    #
    def to_xml(builder)
      builder.editorialgroup do |b|
        b.society society if society
        balloting_group&.to_xml(b)
        b.send :"working-group", working_group if working_group
        committee.each { |c| b.committee c }
      end
    end

    #
    # Render editorial group to Hash
    #
    # @return [Hash] editorial group as Hash
    #
    def to_hash
      hash = {}
      hash["society"] = society if society
      hash["balloting_group"] = balloting_group.to_hash if balloting_group
      hash["working_group"] = working_group if working_group
      hash["committee"] = committee if committee
      hash
    end

    #
    # Render editorial group to AsciiBib
    #
    # @param [String] prefix Prefix
    #
    # @return [String] AsciiBib
    #
    def to_asciibib(prefix = "")
      pref = prefix.empty? ? prefix : "#{prefix}."
      pref += "editorialgroup"
      out = ""
      out += "#{pref}.society:: #{society}\n" if society
      out += balloting_group.to_asciibib(pref) if balloting_group
      out += "#{pref}.working-group:: #{working_group}\n" if working_group
      committee.each { |c| out += "#{pref}.committee:: #{c}\n" }
      out
    end
  end
end
