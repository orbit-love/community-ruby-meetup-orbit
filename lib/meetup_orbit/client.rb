# frozen_string_literal: true

require 'dotenv/load'
require 'net/http'
require 'json'

# Create a client to log Meetup activities in your Orbit workspace
# Credentials can either be passed in to the instance or be loaded
# from environment variables
#
# @example
#   client = MeetupOrbit::Client.new
#
# @option params [String] :orbit_api_key
#   The API key for the Orbit API
#
# @option params [String] :orbit_workspace
#   The workspace ID for the Orbit workspace
#
# @option params [String] :meetup_urlname
#   The URL identifier of your Meetup
#
# @param [Hash] params
#
# @return [MeetupOrbit::Client]
#
module MeetupOrbit
  class Client
    attr_accessor :orbit_api_key, :orbit_workspace, :meetup_urlname

    def initialize(params = {})
      @orbit_api_key = params.fetch(:orbit_api_key, ENV['ORBIT_API_KEY'])
      @orbit_workspace = params.fetch(:orbit_workspace, ENV['ORBIT_WORKSPACE_ID'])
      @meetup_urlname = check_urlname(params.fetch(:meetup_urlname, ENV['MEETUP_URLNAME']))
    end

    def event_rsvps
      MeetupOrbit::Meetup.new(
        meetup_urlname: @meetup_urlname,
        orbit_api_key: @orbit_api_key,
        orbit_workspace: @orbit_workspace
      ).process_event_rsvps
    end

    private

    def check_urlname(urlname)
      if urlname.start_with?('http://') || urlname.start_with?('https://') || urlname.start_with?('www') || urlname.start_with?('meetup.com')
        raise ArgumentError,
              "'meetup_urlname' parameter must only be the unique identifier of your meetup not the entire URL. Please refer to the README for more details."
      end

      urlname
    end
  end
end
