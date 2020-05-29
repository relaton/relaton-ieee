module RelatonIeee
  class HashConverter < RelatonBib::HashConverter
    class << self
      # @param args [Hash]
      # @param neated [TrueClas, FalseClass] default true
      # @return [Hash]
      def hash_to_bib(args, nested = false)
        hash = super
        return nil unless hash.is_a?(Hash)

        committee_hash_to_bib hash
        hash
      end

      # @param item_hash [Hash]
      # @return [RelatonIeee::IeeeBibliographicItem]
      def bib_item(item_hash)
        IeeeBibliographicItem.new item_hash
      end

      # @param hash [Hash]
      def committee_hash_to_bib(hash)
        return unless hash[:committee]

        hash[:committee] = hash[:committee].map { |c| Committee.new c }
      end
    end
  end
end
