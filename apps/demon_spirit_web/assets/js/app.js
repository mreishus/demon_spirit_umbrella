// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html";

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import { Socket } from "phoenix";

//import LiveSocket from "phoenix_live_view";
import * as LiveView from "phoenix_live_view";
const { LiveSocket } = LiveView;

let Hooks = {};

import PhoneNumber from "./hooks/phone_number";
Hooks.PhoneNumber = PhoneNumber;

import Draggable from "./hooks/draggable";
Hooks.Draggable = Draggable;

import Droppable from "./hooks/droppable";
Hooks.Droppable = Droppable;

import DraggableDroppable from "./hooks/draggable_droppable";
Hooks.DraggableDroppable = DraggableDroppable;

import UpdateDing from "./hooks/update_ding";
Hooks.UpdateDing = UpdateDing;

import ChatScroll from "./hooks/chat_scroll";
Hooks.ChatScroll = ChatScroll;

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
});
liveSocket.connect();
