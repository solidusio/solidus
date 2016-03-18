$(function(){
  $('body').tooltip({selector: '.with-tip'})

  $('body').on('inserted.bs.tooltip', function(e){
    var $target = $(e.target);
    var $tooltip = $("#" + $target.attr("aria-describedby"));
    $tooltip.addClass("action-" + $target.data("action"));
  });
});
