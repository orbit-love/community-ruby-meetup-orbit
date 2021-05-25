# frozen_string_literal: true

module MeetupOrbit
    class Meetup
        def initialize(params = {})
            @meetup_urlname = params.fetch(:meetup_urlname)
            @orbit_api_key = params.fetch(:orbit_api_key)
            @orbit_workspace = params.fetch(:orbit_workspace)
        end

        def process_event_rsvps
            events = get_events

            events.each do |event|
                next if event["yes_rsvp_count"] <= 1 || event["yes_rsvp_count"].nil?

                rsvps = get_rsvps(event["id"])

                rsvps.drop(1).each do |rsvp| # skip first item which is event owner
                    MeetupOrbit::Orbit.call(
                        type: "event_rsvp",
                        data: {
                            rsvp: {
                                event: rsvp["event"]["name"],
                                group: rsvp["group"]["name"],
                                member_id: rsvp["member"]["id"],
                                member_name: rsvp["member"]["name"],
                                occurred_at: Time.at(rsvp["created"] / 1000).utc,
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
        end

        def get_events
            url = URI("https://api.meetup.com/#{@meetup_urlname}/events")

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
    end
end