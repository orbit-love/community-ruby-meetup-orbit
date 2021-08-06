# frozen_string_literal: true

require "json"

module MeetupOrbit
  module Interactions::Events
    class Rsvp
      def initialize(rsvp:, orbit_workspace:, orbit_api_key:)
        @rsvp = rsvp
        @orbit_workspace = orbit_workspace
        @orbit_api_key = orbit_api_key

        after_initialize!
      end

      def after_initialize!
        OrbitActivities::Request.new(
          api_key: @orbit_api_key,
          workspace_id: @orbit_workspace,
          user_agent: "community-ruby-meetup-orbit/#{MeetupOrbit::VERSION}",
          action: "new_activity",
          body: construct_body.to_json
        )
      end

      def construct_body
        hash = {
          activity: {
            activity_type: "meetup:rsvp",
            tags: ["channel:meetup"],
            title: "New RSVP for #{@rsvp[:event]}",
            description: construct_description,
            occurred_at: @rsvp[:occurred_at],
            key: @rsvp[:id],
            link: @rsvp[:link],
            member: {
              name: @rsvp[:member_name]
            }
          },
          identity: {
            source: "meetup",
            name: @rsvp[:member_name],
            uid: @rsvp[:member_id]
          }
        }
      end

      def construct_description
        <<~HEREDOC
          #{@rsvp[:member_name]} has registered for #{@rsvp[:event]} in the #{@rsvp[:group]} Meetup group
        HEREDOC
      end
    end
  end
end
