module RelatonIeee
  class DocumentStatus < RelatonBib::DocumentStatus
    class Stage < RelatonBib::DocumentStatus::Stage
      STAGES = %w[draft approved superseded withdrawn].freeze

      def initialize(value:, abbreviation: nil)
        unless STAGES.include?(value.downcase)
          Util.warn "Stage value must be one of: `#{STAGES.join('`, `')}`"
        end
        super
      end
    end
  end
end
