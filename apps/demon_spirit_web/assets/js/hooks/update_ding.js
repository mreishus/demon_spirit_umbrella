let move_audio = new Audio();
move_audio.src = '/sounds/move.mp3';

let UpdateDing = {
  updated() {
    move_audio.play();
  }
};
export default UpdateDing;
