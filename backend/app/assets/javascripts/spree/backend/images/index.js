Spree.ready(function() {
  $('#new_image_link').click(function(event) {
    event.preventDefault();

    $('.no-objects-found').hide();

    $(this).hide();
    Spree.ajax({
      type: 'GET',
      url: this.href,
      success: function(r) {
        $('#images').html(r);
        $('select.select2').select2();
      }
    });
  });
});
