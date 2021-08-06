#!/usr/bin/env ruby
# frozen_string_literal: true

require "meetup_orbit"
require "thor"

module MeetupOrbit
  module Scripts
    class CheckRsvps < Thor
      desc "render", "check for new Meetup event RSVPs and push them to Orbit"
      def render(*params)
        client = MeetupOrbit::Client.new(historical_import: params[0])
        client.event_rsvps
      end
    end
  end
end