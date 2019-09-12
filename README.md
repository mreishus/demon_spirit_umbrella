# DemonSpirit.Umbrella

*Demon Spirit*, an abstract board game on a 5x5 grid.

# Organization

* DemonSpiritGame.*

  Game logic.  All functions for tracking and changing game state.
* DemonSpiritWeb.*

  Phoenix app that will allow users to play the game online.  Will use either LiveView or React.
* DemonSpirit

  If the web app ever tracks user accounts, win records, etc, the data models and associated functions
  will be here.  Initial implementation will be anonymous sessions only.

# Status

*Heavy WIP*. 

`DemonSpiritGame` - ~90% done. Mostly built out and tested, with GenServers, a dynamic supervisor and a process registry.  Will probably need some sort of "What cards can this move, (specified by a pair of coordinates) use?" function that's used by the UI.

`DemonSpiritWeb` - Added Guest login (no automated tests).  Need to build lobby, game creation and selection mechanism: Want games with a specific url that spawns a GenServer running `DemonSpiritGame`.  Need to build UI reflecting game state.  Need to allow users to move pieces.  

Current task:  Building out `DemonSpiritWeb` module.
