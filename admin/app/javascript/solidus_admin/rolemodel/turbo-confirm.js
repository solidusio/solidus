import TC from "@rolemodel/turbo-confirm"

TC.start({
  messageSlotSelector: ".modal-title",
  contentSlots: {
    body: {
      contentAttribute: "confirm-details",
      slotSelector: ".modal-body"
    },
    acceptText: {
      contentAttribute: "confirm-button",
      slotSelector: "#confirm-accept"
    }
  }
});
