// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"

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

let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks});
liveSocket.connect();
