import { debounce } from "debounce";

let isAtBottom = {};

const scrollHandler = e => {
  let chatId = e.target.dataset.chatId;
  if (!chatId) {
    return;
  }

  isAtBottom[chatId] =
    e.target.scrollTop + e.target.clientHeight > e.target.scrollHeight - 12;
};

let ChatScroll = {
  mounted() {
    let el = this.el;
    if (!el.dataset.chatId) {
      console.warn(
        "ChatScroll hook: Please place a unique [data-chat-id] element on the hooked div.  Refusing to operate."
      );
      return;
    }

    // Scroll to bottom when first mounting
    el.scrollTop = el.scrollHeight;

    // Whenever scroll position changes,
    // mark if we're at the bottom or not
    el.addEventListener("scroll", debounce(scrollHandler, 150));
  },
  updated() {
    // Scroll to bottom when a new message comes in
    let el = this.el;
    let chatId = el.dataset.chatId;
    if (!chatId) {
      return;
    }

    if (isAtBottom[chatId]) {
      el.scrollTop = el.scrollHeight;
    }
  }
};
export default ChatScroll;
