const patch = function(fnName) {
  const originalFn = this[fnName];
  this.hook("instead", fnName, function() {
    const originalScrollToOption = this.scrollToOption;

    this.scrollToOption = () => {};
    originalFn.apply(this, arguments);
    this.scrollToOption = originalScrollToOption;
  });
}

// https://github.com/orchidjs/tom-select/issues/556
// https://github.com/orchidjs/tom-select/issues/867
export default function() {
  this.on("initialize", function() {
    patch.call(this, "onOptionSelect");
    patch.call(this, "loadCallback");
  })
}
