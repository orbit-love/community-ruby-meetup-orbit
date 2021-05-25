# frozen_string_literal: true

require "spec_helper"

RSpec.describe MeetupOrbit::Client do
  let(:subject) do
    MeetupOrbit::Client.new(
      orbit_api_key: "12345",
      orbit_workspace: "test",
      meetup_urlname: "test-123"
    )
  end

  it "initializes with arguments passed in directly" do
    expect(subject).to be_truthy
  end

  it "initializes with credentials from environment variables" do
    allow(ENV).to receive(:[]).with("ORBIT_API_KEY").and_return("12345")
    allow(ENV).to receive(:[]).with("ORBIT_WORKSPACE").and_return("test")
    allow(ENV).to receive(:[]).with("MEETUP_URLNAME").and_return("test-123")

    expect(MeetupOrbit::Client).to be_truthy
  end
end