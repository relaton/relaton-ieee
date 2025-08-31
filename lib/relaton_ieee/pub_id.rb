module RelatonIeee
  class PubId
    class Id
      # @return [String]
      attr_reader :number

      # @return [String, nil]
      attr_reader :publisher, :std, :stage, :part, :status, :approval, :edition,
                  :draft, :rev, :corr, :amd, :redline, :year, :month

      #
      # PubId constructor
      #
      # @param [String] number
      # @param [<Hash>] **args
      # @option args [String] :number
      # @option args [String] :publisher
      # @option args [Boolean] :std
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
      def initialize(number:, **args) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        @publisher = args[:publisher]
        @std = args[:std]
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
      # @param [Boolean] trademark if true, add trademark symbol
      #
      # @return [String]
      #
      def to_s(trademark: false) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        out = number
        out = "Std #{out}" if std
        out = "#{stage} #{out}" if stage
        out = "#{approval} #{out}" if approval
        out = "#{status} #{out}" if status
        out = "#{publisher} #{out}" if publisher
        out += ".#{part}" if part
        if trademark
          out += out.match?(/^IEEE\s(Std\s)?(802|2030)/) ? "\u00AE" : "\u2122"
        end
        out += edition_to_s + draft_to_s + rev_to_s + corr_to_s + amd_to_s
        out + year_to_s + month_to_s + redline_to_s
      end

      def edition_to_s
        edition ? "/E-#{edition}" : ""
      end

      def draft_to_s
        draft ? "/D-#{draft}" : ""
      end

      def rev_to_s
        rev ? "/R-#{rev}" : ""
      end

      def corr_to_s
        corr ? "/Cor#{corr}" : ""
      end

      def amd_to_s
        amd ? "/Amd#{amd}" : ""
      end

      def year_to_s
        year ? "-#{year}" : ""
      end

      def month_to_s
        month ? "-#{month}" : ""
      end

      def redline_to_s
        redline ? " Redline" : ""
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
    # @param [Boolean] trademark if true, add trademark symbol
    #
    # @return [String]
    #
    def to_s(trademark: false)
      pubid.map { |id| id.to_s(trademark: trademark) }.join("/")
    end

    #
    # Generate ID without publisher and second number
    #
    # @return [String]
    #
    def to_id # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      out = pubid[0].to_s
      if pubid.size > 1
        out += pubid[1].edition_to_s if pubid[0].edition.nil?
        out += pubid[1].draft_to_s if pubid[0].draft.nil?
        out += pubid[1].rev_to_s if pubid[0].rev.nil?
        out += pubid[1].corr_to_s if pubid[0].corr.nil?
        out += pubid[1].amd_to_s if pubid[0].amd.nil?
        out += pubid[1].year_to_s if pubid[0].year.nil?
        out += pubid[1].month_to_s if pubid[0].month.nil?
        out += pubid[1].redline_to_s unless pubid[0].redline
      end
      out
    end
  end
end
