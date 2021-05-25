# frozen_string_literal: true

require "spec_helper"

RSpec.describe MeetupOrbit::Interactions::Events::Rsvp do
  let(:subject) do
    MeetupOrbit::Interactions::Events::Rsvp.new(
      rsvp: {
        event: "Sample Event",
        group: "Sample Group",
        member_id: "123",
        member_name: "Jean-Luc Picard",
        occurred_at: "2021-05-25 08:17:50 UTC",
        id: "123-456",
        link: "https://www.meetup.com/sample-meetup-123/events/456",
        response: "yes"
      },
      orbit_workspace: "1234",
      orbit_api_key: "12345"
    )
  end

  describe "#call" do
    context "when the type is a rsvp" do
      it "returns a Rsvp Object" do
        stub_request(:post, "https://app.orbit.love/api/v1/1234/activities")
          .with(
            headers: { 'Authorization' => "Bearer 12345", 'Content-Type' => 'application/json' },
            body: "{\"activity\":{\"activity_type\":\"meetup:rsvp\",\"tags\":[\"channel:meetup\"],\"title\":\"New RSVP for Sample Event\",\"description\":\"Jean-Luc Picard has registered for Sample Event in the Sample Group Meetup group\\n\",\"occurred_at\":\"2021-05-25 08:17:50 UTC\",\"key\":\"123-456\",\"link\":\"https://www.meetup.com/sample-meetup-123/events/456\",\"member\":{\"name\":\"Jean-Luc Picard\"}},\"identity\":{\"source\":\"meetup\",\"name\":\"Jean-Luc Picard\",\"uid\":\"123\"}}"
          )
          .to_return(
            status: 200,
            body: {
              response: {
                code: 'SUCCESS'
              }
            }.to_json.to_s
          )

        content = subject.construct_body

        expect(content[:activity][:key]).to eql("123-456")
      end
    end
  end
end