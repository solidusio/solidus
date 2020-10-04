Spree.ready(function() {
  // Highlight negative numbers in red.
  document.querySelector('body').addEventListener('input', function(e){
    var el = e.target;
    var isInputNumber = el instanceof HTMLInputElement && el.type == 'number';
    if (isInputNumber) {
      if (el.value < 0) {
        el.classList.add("negative");
      } else {
        el.classList.remove("negative");
      }
    }
  });
});
