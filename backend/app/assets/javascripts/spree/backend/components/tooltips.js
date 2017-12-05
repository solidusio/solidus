Spree.ready(function(){
  $('body').popover({selector: '.hint-tooltip', html: true, trigger: 'hover', placement: 'top'});

  $('body').tooltip({selector: '.with-tip'});

  $('body').on('inserted.bs.tooltip', function(e){
    var $target = $(e.target);
    var tooltip = $target.data('bs.tooltip');

    /*
     * Observe target changes to understand if we need to remove tooltips.
     *
     * This is necessary to fix tooltips hanging around after their attached
     * element has been removed from the DOM (and will therefore receive no
     * mouseleave event).
     */
    var observer = new MutationObserver(function(mutations) {
      // disconnect itself when content is changed, a new observer will
      // be attached to this element when the new tooltip is created.
      this.disconnect();

      tooltip.hide();
    });
    observer.observe($target.get(0), { attributes: true });

    var $tooltip = $("#" + $target.attr("aria-describedby"));
    $tooltip.addClass("action-" + $target.data("action"));
  });
});
