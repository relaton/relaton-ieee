require_relative "balloting_group"

module Relaton
  module Ieee
    class EditorialGroup < Lutaml::Model::Serializable
      attribute :society, :string
      attribute :balloting_group, BallotingGroup
      attribute :working_group, :string
      attribute :committee, :string

      xml do
        map_element "society", to: :society
        map_element "balloting-group", to: :balloting_group
        map_element "working-group", to: :working_group
        map_element "committee", to: :committee
      end
    end
  end
end
