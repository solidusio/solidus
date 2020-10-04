Spree.ready(function(){
  $('body').popover({selector: '.hint-tooltip', html: true, trigger: 'hover', placement: 'top'});

  $('body').tooltip({selector: '.with-tip'});

  /*
   * Poll tooltips to hide them if they are no longer being hovered.
   *
   * This is necessary to fix tooltips hanging around after their attached
   * element has been removed from the DOM (and will therefore receive no
   * mouseleave event). This may be unnecessary in a future version of
   * bootstrap, which intends to solve this using MutationObserver.
   */
  var removeDesyncedTooltip = function(tooltip) {
    var interval = setInterval(function(){
      if(!$(tooltip.element).is(":hover")) {
        tooltip.dispose();
        clearInterval(interval);
      }
    }, 200);
    $(tooltip.element).on('hidden.bs.tooltip', function(){
      clearInterval(interval);
    });
  };

  $('body').on('inserted.bs.tooltip', function(e){
    var $target = $(e.target);
    var tooltip = $target.data('bs.tooltip');
    removeDesyncedTooltip(tooltip);
    var $tooltip = $("#" + $target.attr("aria-describedby"));
    $tooltip.addClass("action-" + $target.data("action"));
  });
});
