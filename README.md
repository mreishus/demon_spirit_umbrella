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

*Heavy WIP*.  Current task:  Building out `DemonSpiritGame` module.
