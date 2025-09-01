module RelatonIeee
  module HashConverter
    include RelatonBib::HashConverter
    extend self
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
      eg = hash.dig(:ext, :editorialgroup) || hash[:editorialgroup]
      return unless eg

      hash[:editorialgroup] = EditorialGroup.new(**eg)
    end

    def ext_hash_to_bib(hash)
      ext = hash.delete(:ext)
      return unless ext

      attrs = %i[standard_status standard_modified pubstatus holdstatus]
      ext.select { |k, _| attrs.include? k }.each do |k, v|
        hash[k] = v
      end
    end

    def create_doctype(**args)
      DocumentType.new(**args)
    end
  end
end
