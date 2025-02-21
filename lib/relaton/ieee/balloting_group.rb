module Relaton
  module Ieee
    class BallotingGroup < Lutaml::Model::Serializable
      attribute :type, :string, values: %w[individual entity]
      attribute :content, :string

      xml do
        map_attribute "type", to: :type
        map_content to: :content
      end
    end
  end
end
