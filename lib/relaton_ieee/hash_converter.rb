module RelatonIeee
  class HashConverter < RelatonBib::HashConverter
    class << self
      # @param args [Hash]
      # @param neated [TrueClas, FalseClass] default true
      # @return [Hash]
      def hash_to_bib(args)
        hash = super
        return unless hash.is_a?(Hash)

        # editorialgroup_hash_to_bib hash
        ext_hash_to_bib hash
        hash
      end

      # @param item_hash [Hash]
      # @return [RelatonIeee::IeeeBibliographicItem]
      def bib_item(item_hash)
        IeeeBibliographicItem.new(**item_hash)
      end

      # @param hash [Hash]
      def editorialgroup_hash_to_bib(hash)
        return unless hash[:editorialgroup]

        hash[:editorialgroup] = EditorialGroup.new(**hash[:editorialgroup])
      end

      def ext_hash_to_bib(hash)
        ext = hash.delete(:ext)
        return unless ext

        attrs = %i[standard_status standard_modifier pubstatus holdstatus]
        ext.select { |k, _| attrs.include? k }.each do |k, v|
          hash[k] = v
        end
      end
    end
  end
end
