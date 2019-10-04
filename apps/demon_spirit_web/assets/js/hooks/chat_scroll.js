let ChatScroll = {
  mounted() {
    // Scroll to bottom when first mounting
    let el = this.el;
    el.scrollTop = el.scrollHeight;
  },
  updated() {
    // Scroll to bottom when a new message comes in

    // Problem: If you're scrolled up, looking at history when
    // new messages come in, your scroll position is disrupted

    // React provides getSnapshotBeforeUpdate(), I don't
    // think Phx-Hook has anything like this.  So how would I
    // check the scroll position just before an update comes in?
    let el = this.el;
    el.scrollTop = el.scrollHeight;
  }
};
export default ChatScroll;
