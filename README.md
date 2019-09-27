# DemonSpirit.Umbrella

*Demon Spirit*, an abstract board game on a 5x5 grid.

# Status

*Alpha version is deployed at [https://demonspirit.xyz/](https://demonspirit.xyz/). It's buggy.*

# Most Important Issues

* Drag and drop does not work.
* No way to move pieces on the iphone: Clicking does nothing.
* Players should not see what piece their opponents are selecting.
* No indication when a player has left the game (closed the browser window).  You could be waiting a long time for a missing opponent.
* No chess timer.
* Link to game in waiting window is missing domain name.
* Automated tests missing on web layer.
* No CI/CD pipeline.
* Kubernetes hosting does not use Deployment resource, only ReplicaSet.  No clear strategy for rolling out new deployments at the moment.
* Add a chat window?

# Organization

* DemonSpiritGame.*

  Game logic.  All functions for tracking and changing game state.
* DemonSpiritWeb.*

  Phoenix app that will allow users to play the game online.  Will use either LiveView or React.
* DemonSpirit

  If the web app ever tracks user accounts, win records, etc, the data models and associated functions
  will be here.  Initial implementation will be anonymous sessions only.


Current view:

![Early Screenshot](/screenshot2.png?raw=true "Early Screenshot")
