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

  it "raises an exception of meetup urlname parameter is a URL starting with https" do
    expect { client = MeetupOrbit::Client.new(
      orbit_api_key: "12345",
      orbit_workspace: "test",
      meetup_urlname: "https://www.meetup.com/test-123"
    ) }.to raise_error(ArgumentError, "'meetup_urlname' parameter must only be the unique identifier of your meetup not the entire URL. Please refer to the README for more details.")
  end

  it "raises an exception of meetup urlname parameter is a URL starting with http" do
    expect { client = MeetupOrbit::Client.new(
      orbit_api_key: "12345",
      orbit_workspace: "test",
      meetup_urlname: "http://www.meetup.com/test-123"
    ) }.to raise_error(ArgumentError, "'meetup_urlname' parameter must only be the unique identifier of your meetup not the entire URL. Please refer to the README for more details.")
  end

  it "raises an exception of meetup urlname parameter is a URL starting with www" do
    expect { client = MeetupOrbit::Client.new(
      orbit_api_key: "12345",
      orbit_workspace: "test",
      meetup_urlname: "www.meetup.com/test-123"
    ) }.to raise_error(ArgumentError, "'meetup_urlname' parameter must only be the unique identifier of your meetup not the entire URL. Please refer to the README for more details.")
  end

  it "raises an exception of meetup urlname parameter is a URL starting with meetup.com" do
    expect { client = MeetupOrbit::Client.new(
      orbit_api_key: "12345",
      orbit_workspace: "test",
      meetup_urlname: "meetup.com/test-123"
    ) }.to raise_error(ArgumentError, "'meetup_urlname' parameter must only be the unique identifier of your meetup not the entire URL. Please refer to the README for more details.")
  end
end