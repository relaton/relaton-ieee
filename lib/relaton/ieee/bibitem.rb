module Relaton
  module Ieee
    class Bibitem < Item
      model ItemData
      include Bib::BibitemShared
    end
  end
end
