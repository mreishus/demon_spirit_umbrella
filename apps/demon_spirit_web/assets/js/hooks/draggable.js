let Draggable = {
  mounted() {
    let pushEvent = (x, y) => this.pushEvent(x, y);

    this.el.addEventListener('dragstart', e => {
      // Putting fake data on it is required to make it draggable in FireFox
      let sx = parseInt(this.el.dataset.x, 10);
      let sy = parseInt(this.el.dataset.y, 10);
      e.dataTransfer.setData('sx', sx);
      e.dataTransfer.setData('sy', sy);
      pushEvent('drag-piece', {sx, sy});
    });
    this.el.addEventListener('dragend', e => {
      pushEvent('drag-end', null);
    });
  }
};
let m = Draggable.mounted;
export { m as draggableMounted };
export default Draggable;
