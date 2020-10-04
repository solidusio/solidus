Spree.ready(function() {
  $(document).ajaxStart(function() {
    $("#progress").show();
  });

  $(document).ajaxStop(function() {
    $("#progress").hide();
  });
});
