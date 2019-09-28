// This is a workaround to phx-hook only allowing one hook.
import {draggableMounted} from "./draggable.js";
import {droppableMounted} from "./droppable.js";
let DraggableDroppable = {
  mounted() {
    draggableMounted.apply(this);
    droppableMounted.apply(this);
  }
};

export default DraggableDroppable;
