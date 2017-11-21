Spree.ready(function() {
  $('#new_image_link').click(function(event) {
    event.preventDefault();

    $(this).hide();
    $('#new_image').show();
  });
});
