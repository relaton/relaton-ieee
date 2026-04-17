require_relative "doctype"

module Relaton
  module Ieee
    class Ext < Bib::Ext
      attribute :doctype, Doctype
      attribute :subdoctype, :string, values: %w[amendment corrigendum erratum]
      attribute :trial_use, :boolean
      attribute :standard_status, :string, values: %w[Inactive Active Superseded]
      attribute :standard_modified, :string, values: %w[Draft Withdrawn Superseded Superseded Reserved Redline]
      attribute :pubstatus, :string, values: %w[Active Inactive]
      attribute :holdstatus, :string, values: %w[Hold Publish]
      attribute :program, :string

      xml do
        map_element "trial-use", to: :trial_use
        map_element "standard_status", to: :standard_status
        map_element "standard_modified", to: :standard_modified
        map_element "pubstatus", to: :pubstatus
        map_element "holdstatus", to: :holdstatus
        map_element "program", to: :program
      end

      key_value do
        map_element "trial_use", to: :trial_use
        map_element "standard_status", to: :standard_status
        map_element "standard_modified", to: :standard_modified
        map_element "pubstatus", to: :pubstatus
        map_element "holdstatus", to: :holdstatus
        map_element "program", to: :program
      end

      def get_schema_version = Relaton.schema_versions["relaton-model-ieee"]
    end
  end
end
