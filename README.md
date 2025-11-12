

![albo](https://content.api.news/v3/images/bin/c1379c4a5c951e0c1116ca406e5cc68c)

Hi there, PM here. This is your reminder that the right to disconnect is now law.   
Because if you're not being paid 24 hours a day, you shouldn't be on call 24 hours a day either.

[Right to disconnect](https://www.fairwork.gov.au/employment-conditions/hours-of-work-breaks-and-rosters/right-to-disconnect)


## About
Self hostable discord bot that reminds members of a guild about the right to disconnect under Australian law.

![example](/images/example.png)

## Features
- Automated alerts at 5PM AEST weekdays that reminds members about the right to disconnect.
- Slash commands that ping specific members with   
    - a reminder about the right to disconnect
    - check in to see if they have disconnected for the day
- Randomised attachment of specific clips of albo mentioning the right to disconnect


### Requirements
Parameter requirements (see .env.example)
- Discord Bot Token
- Discord Bot App Id
- Discord Guild Id (Of the guild the bot will/has joined)
- Discord Channel Id (Of the channel you wish for automated alerts to be sent to)

### Running/Compiling
1.  Run ```mix deps.get``` to pull dependencies
2.  Run ```mix compile``` to compile project
3.  ```mix run``` or ```iex -S mix``` to run

#### Building for docker
- ```docker build -t albo:latest .```     

Made with Elixir & Nostrum
