let move_audio = new Audio();
move_audio.src = "/sounds/move.mp3";

let moves = 0;

let UpdateDing = {
  updated() {
    let new_moves = this.el.getAttribute("data-moves");
    if (new_moves != moves) {
      moves = new_moves;
      move_audio.play();
    }
  }
};
export default UpdateDing;
