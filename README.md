  > **Warning**
  > This repository is no longer recommended or maintained and has now been archived. Huge thanks to the original authors and contributors for providing this to our community. Should you wish to maintain your own version of this repository, you are welcome to fork this repository and continue developing it there.
  
  ---

# Meetup Interactions to Orbit Workspace

![Build Status](https://github.com/orbit-love/community-ruby-meetup-orbit/workflows/CI/badge.svg)
[![Gem Version](https://badge.fury.io/rb/meetup_orbit.svg)](https://badge.fury.io/rb/meetup_orbit)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.0-4baaaa.svg)](.github/CODE_OF_CONDUCT.md)

Add your Meetup interactions into your Orbit workspace with this community-built integration.

![New RSVP in Orbit screenshot](readme-images/new-rsvp-screenshot.png)

|<p align="left">:sparkles:</p> This is a *community project*. The Orbit team does its best to maintain it and keep it up to date with any recent API changes.<br/><br/>We welcome community contributions to make sure that it stays current. <p align="right">:sparkles:</p>|
|-----------------------------------------|

![There are three ways to use this integration. Install package - build and run your own applications. Run the CLI - run on-demand directly from your terminal. Schedule an automation with GitHub - get started in minutes - no coding required](readme-images/ways-to-use.png)

## First Time Setup

To set up this integration you will need your Meetup group's URL identifier. See the below table for instructions on where to find it, along with your Orbit API credentials.
## Application Credentials

The application requires the following environment variables:

| Variable | Description | More Info
|---|---|--|
| `MEETUP_URLNAME` | Meetup group URL identifier | The part of your Meetup group URL immediately after `meetup.com`, i.e. `https://www.meetup.com/meetup-group-example-123/`, the URL ID is `meetup-group-example-123`
| `ORBIT_API_KEY` | API key for Orbit | Found in `Account Settings` in your Orbit workspace
| `ORBIT_WORKSPACE_ID` | ID for your Orbit workspace | Last part of the Orbit workspace URL, i.e. `https://app.orbit.love/my-workspace`, the ID is `my-workspace`

## Package Usage

Install the package with the following command

```
$ gem install meetup_orbit
```

Then, run `bundle install` from your terminal.

You can instantiate a client by either passing in the required credentials during instantiation or by providing them in your `.env` file.

### Instantiation with credentials:

```ruby
client = MeetupOrbit::Client.new(
    orbit_api_key: YOUR_API_KEY,
    orbit_workspace_id: YOUR_ORBIT_WORKSPACE_ID,
    meetup_urlname: YOUR_MEETUP_URLNAME
)
```

### Instantiation with credentials in dotenv file:

```ruby
client = MeetupOrbit::Client.new
```
### Performing a Historical Import

You may want to perform a one-time historical import to fetch all your previous Meetup interactions and bring them into your Orbit workspace. To do so, instantiate your `client` with the `historical_import` flag:

```ruby
client = MeetupOrbit::Client.new(
  historical_import: true
)
```
### Fetching New Event RSVPs

Once, you have an instantiated client, you can fetch new Meetup event RSVPs and add them to your Orbit workspace by invoking the `#event_rsvps` method on the client:

```ruby
client.event_rsvps
```
## CLI Usage

You can also use this package with the included CLI. To use the CLI pass in the required environment variables on the command line before invoking the CLI.

To check for new event RSVPs:

```bash
$ ORBIT_API_KEY=... ORBIT_WORKSPACE_ID=... MEETUP_URLNAME=... bundle exec meetup_orbit --check-rsvps
```

**Add the `--historical-import` flag to your CLI command to perform a historical import of all your Meetup interactions using the CLI.**

## GitHub Actions Automation Setup

⚡ You can set up this integration in a matter of minutes using our GitHub Actions template. It will run regularly to add new activities to your Orbit workspace. All you need is a GitHub account.

[See our guide for setting up this automation](https://github.com/orbit-love/github-actions-templates/blob/main/Meetup/README.md)

## Contributing

We 💜 contributions from everyone! Check out the [Contributing Guidelines](.github/CONTRIBUTING.md) for more information.

## License

This project is under the [MIT License](./LICENSE).

## Code of Conduct

This project uses the [Contributor Code of Conduct](.github/CODE_OF_CONDUCT.md). We ask everyone to please adhere by its guidelines.
