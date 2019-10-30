# Issues

## Most Important Issues

- No indication when a player has left the game (closed the browser window).
  You could be waiting a long time for a missing opponent.
- Can't specify time controls when making a game
- Automated tests missing on web layer.
- No CI/CD pipeline.
- Kubernetes hosting does not use Deployment resource, only ReplicaSet. No
  clear strategy for rolling out new deployments at the moment.
- Misalignment of squares (Highlight doesn't line up properly)

## Fixed Issues

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
