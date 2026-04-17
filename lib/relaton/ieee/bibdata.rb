module Relaton
  module Ieee
    class Bibdata < Item
      model ItemData
      include Bib::BibdataShared
    end
  end
end
