module Relaton
  module Ieee
    class Doctype < Bib::Doctype
      TYPES = %w[guide recommended-practice standard whitepaper redline other].freeze

      attribute :type, :string, values: TYPES
    end
  end
end
