module RelatonIeee
  module Renderer
    class BibXML < RelatonBib::Renderer::BibXML

      #
      # Render workgroup
      #
      # @param [Nokogiri::XML::Builder] builder xml builder
      #
      def render_workgroup(builder)
        @bib.editorialgroup&.committee&.each do |committee|
          builder.workgroup committee
        end
      end
    end
  end
end
