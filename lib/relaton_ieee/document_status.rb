module RelatonIeee
  class DocumentStatus < RelatonBib::DocumentStatus
    class Stage < RelatonBib::DocumentStatus::Stage
      STAGES = %w[developing active inactive].freeze

      def initialize(value:, abbreviation: nil)
        unless STAGES.include?(value.downcase)
          warn "[relaton-ieee] Stage value must be one of #{STAGES.join(', ')}"
        end
        super
      end
    end
  end
end
