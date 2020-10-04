/* Teaspoon doesn't show errors by default */
window.onerror = function(message) {
  Teaspoon.log(JSON.stringify({
    _teaspoon: true,
    type: "exception",
    message:  message
  }));
}
