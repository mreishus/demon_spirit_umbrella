let Draggable = {
  mounted() {
    console.log("mounted running [draggable]");
    this.el.addEventListener('dragstart', function(e) {
      // Putting fake data on it is required to make it draggable in FireFox
      e.dataTransfer.setData('text', 'foo');
    });
  }
};
export default Draggable;
