# frozen_string_literal: true

require "spec_helper"

RSpec.describe MeetupOrbit::Meetup do
  let(:subject) do
    MeetupOrbit::Meetup.new(
      orbit_api_key: "12345",
      orbit_workspace: "test",
      meetup_urlname: "test-123"
    )
  end

  describe "#process_event_rsvps" do
    context "with historical import set to false and no newer items than the latest activity for the type in Meetup" do
      it "posts no new RSVPs to the Orbit workspace from Meetup" do
        stub_request(:get, "https://app.orbit.love/api/v1/test/activities?activity_type=custom:meetup:rsvp&direction=DESC&items=10")
          .with(
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer 12345",
              "User-Agent" => "community-ruby-meetup-orbit/#{MeetupOrbit::VERSION}"
            }
          )
          .to_return(
            status: 200,
            body: {
              data: [
                {
                  id: "6",
                  type: "spec_activity",
                  attributes: {
                    action: "spec_action",
                    created_at: "2021-07-01T16:03:02.052Z",
                    key: "spec_activity_key#1",
                    occurred_at: "2021-04-01T16:03:02.050Z",
                    type: "SpecActivity",
                    tags: "[\"spec-tag-1\"]",
                    orbit_url: "https://localhost:3000/test/activities/6",
                    weight: "1.0"
                  },
                  relationships: {
                    activity_type: {
                      data: {
                        id: "20",
                        type: "activity_type"
                      }
                    }
                  },
                  member: {
                    data: {
                      id: "3",
                      type: "member"
                    }
                  }
                }
              ]
            }.to_json.to_s,
            headers: {}
          )

        allow(subject).to receive(:get_events).and_return(event_stub)
        allow(subject).to receive(:get_rsvps).with("abc567").and_return(rsvp_stub)

        expect(subject.process_event_rsvps).to eql("Sent 0 new RSVPs to your Orbit workspace")
      end
    end

    context "with historical import set to false and newer items than the latest activity for the type in Orbit" do
      it "posts the newer items to the Orbit workspace from Meetup" do
        stub_request(:post, "https://app.orbit.love/api/v1/test/activities")
          .with(
            body: "{\"activity\":{\"activity_type\":\"meetup:rsvp\",\"tags\":[\"channel:meetup\"],\"title\":\"New RSVP for An Event\",\"description\":\"Spock has registered for An Event in the Meetup Group Meetup group\\n\",\"occurred_at\":\"2021-06-27 21:00:00 UTC\",\"key\":\"abc1234-abc567\",\"link\":\"https://meetup.com/test-123/events/abc567\",\"member\":{\"name\":\"Spock\"}},\"identity\":{\"source\":\"meetup\",\"name\":\"Spock\",\"uid\":\"abc1234\"}}",
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer 12345",
              "Content-Type" => "application/json",
              "User-Agent" => "community-ruby-meetup-orbit/#{MeetupOrbit::VERSION}"
            }
          ).to_return(status: 200, body: {
            response: {
              code: "SUCCESS"
            }
          }.to_json.to_s, headers: {})

        stub_request(:get, "https://app.orbit.love/api/v1/test/activities?activity_type=custom:meetup:rsvp&direction=DESC&items=10")
          .with(
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer 12345",
              "User-Agent" => "community-ruby-meetup-orbit/#{MeetupOrbit::VERSION}"
            }
          )
          .to_return(
            status: 200,
            body: {
              data: [
                {
                  id: "6",
                  type: "spec_activity",
                  attributes: {
                    action: "spec_action",
                    created_at: "2021-06-26T16:03:02.052Z",
                    key: "spec_activity_key#1",
                    occurred_at: "2021-04-01T16:03:02.050Z",
                    type: "SpecActivity",
                    tags: "[\"spec-tag-1\"]",
                    orbit_url: "https://localhost:3000/test/activities/6",
                    weight: "1.0"
                  },
                  relationships: {
                    activity_type: {
                      data: {
                        id: "20",
                        type: "activity_type"
                      }
                    }
                  },
                  member: {
                    data: {
                      id: "3",
                      type: "member"
                    }
                  }
                }
              ]
            }.to_json.to_s,
            headers: {}
          )

        allow(subject).to receive(:get_events).and_return(event_stub)
        allow(subject).to receive(:get_rsvps).and_return(rsvp_stub)

        expect(subject.process_event_rsvps).to eql("Sent 1 new RSVPs to your Orbit workspace")
      end
    end

    context "with historical import set to true" do
      it "posts all items to the Orbit workspace from Meetup" do
        client = MeetupOrbit::Meetup.new(
          orbit_api_key: "12345",
          orbit_workspace: "test",
          meetup_urlname: "test-123",
          historical_import: true
        )

        stub_request(:post, "https://app.orbit.love/api/v1/test/activities")
          .with(
            body: "{\"activity\":{\"activity_type\":\"meetup:rsvp\",\"tags\":[\"channel:meetup\"],\"title\":\"New RSVP for An Event\",\"description\":\"Spock has registered for An Event in the Meetup Group Meetup group\\n\",\"occurred_at\":\"2021-06-27 21:00:00 UTC\",\"key\":\"abc1234-abc567\",\"link\":\"https://meetup.com/test-123/events/abc567\",\"member\":{\"name\":\"Spock\"}},\"identity\":{\"source\":\"meetup\",\"name\":\"Spock\",\"uid\":\"abc1234\"}}",
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer 12345",
              "Content-Type" => "application/json",
              "User-Agent" => "community-ruby-meetup-orbit/#{MeetupOrbit::VERSION}"
            }
          ).to_return(status: 200, body: {
            response: {
              code: "SUCCESS"
            }
          }.to_json.to_s, headers: {})

        stub_request(:post, "https://app.orbit.love/api/v1/test/activities")
          .with(
            body: "{\"activity\":{\"activity_type\":\"meetup:rsvp\",\"tags\":[\"channel:meetup\"],\"title\":\"New RSVP for Another Event\",\"description\":\"Spock has registered for Another Event in the Meetup Group Meetup group\\n\",\"occurred_at\":\"2021-07-19 21:00:00 UTC\",\"key\":\"abc1234-abc789\",\"link\":\"https://meetup.com/test-123/events/abc789\",\"member\":{\"name\":\"Spock\"}},\"identity\":{\"source\":\"meetup\",\"name\":\"Spock\",\"uid\":\"abc1234\"}}",
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer 12345",
              "Content-Type" => "application/json",
              "User-Agent" => "community-ruby-meetup-orbit/#{MeetupOrbit::VERSION}"
            }
          ).to_return(status: 200, body: {
            response: {
              code: "SUCCESS"
            }
          }.to_json.to_s, headers: {})

        stub_request(:get, "https://app.orbit.love/api/v1/test/activities?activity_type=custom:meetup:rsvp&direction=DESC&items=10")
          .with(
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer 12345",
              "User-Agent" => "community-ruby-meetup-orbit/#{MeetupOrbit::VERSION}"
            }
          )
          .to_return(
            status: 200,
            body: {
              data: [
                {
                  id: "6",
                  type: "spec_activity",
                  attributes: {
                    action: "spec_action",
                    created_at: "2021-06-26T16:03:02.052Z",
                    key: "spec_activity_key#1",
                    occurred_at: "2021-04-01T16:03:02.050Z",
                    type: "SpecActivity",
                    tags: "[\"spec-tag-1\"]",
                    orbit_url: "https://localhost:3000/test/activities/6",
                    weight: "1.0"
                  },
                  relationships: {
                    activity_type: {
                      data: {
                        id: "20",
                        type: "activity_type"
                      }
                    }
                  },
                  member: {
                    data: {
                      id: "3",
                      type: "member"
                    }
                  }
                }
              ]
            }.to_json.to_s,
            headers: {}
          )

        allow(client).to receive(:get_events).and_return(events_stub)
        allow(client).to receive(:get_rsvps).and_return(rsvps_stub)

        expect(client.process_event_rsvps).to eql("Sent 4 new RSVPs to your Orbit workspace")
      end
    end
  end

  def event_stub
    [
      {
        "id" => "abc567",
        "yes_rsvp_count" => 2
      }
    ]
  end

  def events_stub
    [
      {
        "id" => "abc567",
        "yes_rsvp_count" => 3
      },
      {
        "id" => "abc789",
        "yes_rsvp_count" => 3
      }
    ]
  end

  def rsvp_stub
    [
      {
        "group" => {
          "name" => "Meetup Group"
        },
        "event" => {
          "id" => "abc567",
          "name" => "An Event"
        },
        "member" => {
          "id" => "ignore_me",
          "name" => "Event Owner"
        },
        "created" => 1624827600,
        "response" => "maybe"
      },
      {
        "group" => {
          "name" => "Meetup Group"
        },
        "event" => {
          "id" => "abc567",
          "name" => "An Event"
        },
        "member" => {
          "id" => "abc1234",
          "name" => "Spock"
        },
        "created" => 1624827600,
        "response" => "yes"
      }
    ]
  end

  def rsvps_stub
    [
      {
        "group" => {
          "name" => "Meetup Group"
        },
        "event" => {
          "id" => "abc567",
          "name" => "An Event"
        },
        "member" => {
          "id" => "ignore_me",
          "name" => "Event Owner"
        },
        "created" => 1624827600,
        "response" => "maybe"
      },
      {
        "group" => {
          "name" => "Meetup Group"
        },
        "event" => {
          "id" => "abc567",
          "name" => "An Event"
        },
        "member" => {
          "id" => "abc1234",
          "name" => "Spock"
        },
        "created" => 1624827600,
        "response" => "yes"
      },
      {
        "group" => {
          "name" => "Meetup Group"
        },
        "event" => {
          "id" => "abc789",
          "name" => "Another Event"
        },
        "member" => {
          "id" => "abc1234",
          "name" => "Spock"
        },
        "created" => 1626728400,
        "response" => "yes"
      }
    ]
  end
end