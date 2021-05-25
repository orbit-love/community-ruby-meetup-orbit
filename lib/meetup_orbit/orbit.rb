# frozen_string_literal: true

module MeetupOrbit
    class Orbit
      def self.call(type:, data:, orbit_workspace:, orbit_api_key:)
        if type == "event_rsvp"
          MeetupOrbit::Interactions::Events::Rsvp.new(
            rsvp: data[:rsvp],
            orbit_workspace: orbit_workspace,
            orbit_api_key: orbit_api_key
          )
        end
      end
    end
  end