# frozen_string_literal: true

module MeetupOrbit
  class Meetup
    def initialize(params = {})
      @meetup_urlname = params.fetch(:meetup_urlname)
      @orbit_api_key = params.fetch(:orbit_api_key)
      @orbit_workspace = params.fetch(:orbit_workspace)
      @historical_import = params.fetch(:historical_import, false)
    end

    def process_event_rsvps
      events = get_events

      times = 0
      events.each do |event|
        next if event["yes_rsvp_count"] <= 1 || event["yes_rsvp_count"].nil?

        rsvps = get_rsvps(event["id"])

        orbit_timestamp = last_orbit_activity_timestamp

        rsvps.drop(1).each do |rsvp| # skip first item which is event owner
            unless @historical_import && orbit_timestamp # rubocop:disable all
                next if Time.at(rsvp["created"] / 1000).utc.to_s < orbit_timestamp unless orbit_timestamp.nil? # rubocop:disable all
            end

            if orbit_timestamp && @historical_import == false
                next if Time.at(rsvp["created"] / 1000).utc.to_s < orbit_timestamp # rubocop:disable all
            end

            times += 1

            MeetupOrbit::Orbit.call(
              type: "event_rsvp",
              data: {
                rsvp: {
                  event: rsvp["event"]["name"],
                  group: rsvp["group"]["name"],
                  member_id: rsvp["member"]["id"],
                  member_name: rsvp["member"]["name"],
                  occurred_at: Time.at(rsvp["created"] / 1000).utc.to_s,
                  id: "#{rsvp["member"]["id"]}-#{rsvp["event"]["id"]}",
                  link: "https://meetup.com/#{@meetup_urlname}/events/#{rsvp["event"]["id"]}",
                  response: rsvp["response"]
                }
              },
              orbit_api_key: @orbit_api_key,
              orbit_workspace: @orbit_workspace
            )
        end
      end

      output = "Sent #{times} new RSVPs to your Orbit workspace"
      puts output
      output
    end

    def get_events
      url =  @historical_import ? URI("https://api.meetup.com/#{@meetup_urlname}/events?status=past,upcoming") :  URI("https://api.meetup.com/#{@meetup_urlname}/events")

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Get.new(url)

      response = https.request(request)

      response = JSON.parse(response.body)
    end

    def get_rsvps(event)
      url = URI("https://api.meetup.com/#{@meetup_urlname}/events/#{event}/rsvps")

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Get.new(url)

      response = https.request(request)

      response = JSON.parse(response.body)
    end

    def last_orbit_activity_timestamp
      @last_orbit_activity_timestamp ||= OrbitActivities::Request.new(
        api_key: @orbit_api_key,
        workspace_id: @orbit_workspace,
        user_agent: "community-ruby-meetup-orbit/#{MeetupOrbit::VERSION}",
        action: "latest_activity_timestamp",
        filters: { activity_type: "custom:meetup:rsvp" }
      ).response
    end
  end
end
