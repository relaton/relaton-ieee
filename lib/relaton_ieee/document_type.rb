module RelatonIeee
  class DocumentType < RelatonBib::DocumentType
    DOCTYPES = %w[guide recommended-practice standard witepaper redline other].freeze

    def initialize(type:, abbreviation: nil)
      check_type type
      super
    end

    def check_type(type)
      unless DOCTYPES.include? type
        Util.warn "Invalid doctype: `#{type}`. It should be one of: `#{DOCTYPES.join('`, `')}`."
      end
    end
  end
end
