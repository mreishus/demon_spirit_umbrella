let Droppable = {
  mounted() {

    let pushEvent = (x, y) => this.pushEvent(x, y);

    this.el.addEventListener('dragover', function(e) {
      e.preventDefault();
    });

    this.el.addEventListener('drop', function(e) {
      // Source X, Y ( What piece was picked up)
      let sx = parseInt(e.dataTransfer.getData('sx'), 10);
      let sy = parseInt(e.dataTransfer.getData('sy'), 10);

      // Target X, Y (What square was dropped on)
      let tx = parseInt(e.target.dataset.x, 10);
      let ty = parseInt(e.target.dataset.y, 10);
      pushEvent('drop-piece', {sx, sy, tx, ty});
    });
  }
};
let m = Droppable.mounted;
export { m as droppableMounted };
export default Droppable;
