# Demon Spirit

_Demon Spirit_, an abstract board game on a 5x5 grid served over the web. You
can play against other players or a computer AI with programmable difficulty.
Built in Elixir, Phoenix, and Phoenix Live View.

## Running the project (Development)

```
mix deps.get
cd ./apps/demon_spirit_web/assets
yarn install
cd ../../../
mix phx.server
```

Visit [http://localhost:4000](http://localhost:4000) in web browser

## Running the project (Production)

Create a Docker Image:

```
edit build.sh with your favorite text editor - change docker tag to your namespace
./build.sh
```

Run the docker image via your favorite method. Expose port 4000 to anywhere
you want, typically 80. Since it doesn't require a database, that's all you
need.

## Linting / Tests / Etc

Run `mix check` to run all tests and linting.

## Online Version

**Newest version is deployed at
[https://demonspirit.xyz/](https://demonspirit.xyz/).**

## Most Important Issues

- No indication when a player has left the game (closed the browser window).
  You could be waiting a long time for a missing opponent.
- Can't specify time controls when making a game
- Automated tests missing on web layer.
- No CI/CD pipeline.
- Kubernetes hosting does not use Deployment resource, only ReplicaSet. No
  clear strategy for rolling out new deployments at the moment.
- Misalignment of squares (Highlight doesn't line up properly)

## Fixed

- If you have a move that could apply to either card, when you use it, you
  don't get to pick which card you want to use.
- No way to move pieces on the iphone: Clicking does nothing.
- Link to game in waiting window is missing domain name.
- Drag and drop does not work.
- Players should not see what piece their opponents are selecting.
- Cards with longer names have a smaller font to avoid line wrapping, however
  there is still some minor visual shifting that's annoying.
- Add a chat window?
- Games don't seem to be dying out even when left alone for hours. Could be
  related to the :ping for vs computer games? (Possible fix implemented)
- No chess timer.

## Organization

- DemonSpiritGame.\*

  Game logic. All functions for tracking and changing game state.

- DemonSpiritWeb.\*

  Phoenix app that will allow users to play the game online. Uses Phoenix
  LiveView.

- DemonSpirit

  If the web app ever tracks user accounts, win records, etc, the data models
  and associated functions will be here. Current implementation is anonymous
  sessions only.

Current view:

![Screenshot](/screenshot.png?raw=true&i=0 "Screenshot")

## Optional Honeycomb Configuration

To report metrics to honeycomb.io, set these environment variables when running:

- HONEYCOMB_APIKEY
- HONEYCOMB_DATASET

Example:

```bash
export HONEYCOMB_APIKEY="012345678912345678abcde123456789"
export HONEYCOMB_DATASET="demonspirit-elixir"
```
