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

## Running the project (Production Test)

```
./test_prod.sh
# Visit http://localhost:4000 in your browser
```

This will create a new docker image named `demon-spirit:test`, and run it,
published to port 4000 on localhost.

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

## Issues

Some issues are tracked in [Issues.MD](./Issues.md).

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

- Lessons Learned

If I were making this app again, I don't think I would use an umbrella
project. I'm not sure the apps are separated cleanly enough to warrant it.

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
