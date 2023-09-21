module RelatonIeee
  module Util
    extend RelatonBib::Util

    def self.logger
      RelatonIeee.configuration.logger
    end
  end
end
