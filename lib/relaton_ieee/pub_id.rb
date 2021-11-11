module RelatonIeee
  class PubId
    class Id
      # @return [String]
      attr_reader :number

      # @return [String, nil]
      attr_reader :publisher, :stage, :part, :status, :approval, :edition,
                  :draft, :rev, :corr, :amd, :redline, :year, :month

      #
      # PubId constructor
      #
      # @param [String] number
      # @param [<Hash>] **args
      # @option args [String] :number
      # @option args [String] :publisher
      # @option args [String] :stage
      # @option args [String] :part
      # @option args [String] :status
      # @option args [String] :approval
      # @option args [String] :edition
      # @option args [String] :draft
      # @option args [String] :rev
      # @option args [String] :corr
      # @option args [String] :amd
      # @option args [Boolean] :redline
      # @option args [String] :year
      # @option args [String] :month
      #
      def initialize(number:, **args)
        @publisher = args[:publisher]
        @stage = args[:stage]
        @number = number
        @part = args[:part]
        @status = args[:status]
        @approval = args[:approval]
        @edition = args[:edition]
        @draft = args[:draft]
        @rev = args[:rev]
        @corr = args[:corr]
        @amd = args[:amd]
        @year = args[:year]
        @month = args[:month]
        @redline = args[:redline]
      end

      #
      # PubId string representation
      #
      # @return [String]
      #
      def to_s
        out = number
        out = "#{stage} #{out}" if stage
        out = "#{approval} #{out}" if approval
        out = "#{status} #{out}" if status
        out = "#{publisher} #{out}" if publisher
        out += "-#{part}" if part
        out += "/E-#{edition}" if edition
        out += "/D-#{draft}" if draft
        out += "/R-#{rev}" if rev
        out += "/Cor#{corr}" if corr
        out += "/Amd#{amd}" if amd
        out += ".#{year}" if year
        out += "-#{month}" if year && month
        out += " Redline" if redline
        out
      end
    end

    # @return [Array<RelatonIeee::PubId::Id>]
    attr_reader :pubid

    #
    # IEEE publication id
    #
    # @param [Array<Hash>, Hash] pubid
    #
    def initialize(pubid)
      @pubid = array(pubid).map { |id| Id.new(**id) }
    end

    #
    # Convert to array
    #
    # @param [Array<Hash>, Hash] pid
    #
    # @return [Array<Hash>]
    #
    def array(pid)
      pid.is_a?(Array) ? pid : [pid]
    end

    #
    # PubId string representation
    #
    # @return [String]
    #
    def to_s
      pubid.map(&:to_s).join("/")
    end
  end
end
