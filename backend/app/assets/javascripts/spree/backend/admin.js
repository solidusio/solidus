//= require_self
//= require spree/backend/handlebars_extensions
//= require spree/backend/variant_autocomplete
//= require spree/backend/taxon_autocomplete
//= require spree/backend/option_type_autocomplete
//= require spree/backend/user_picker
//= require spree/backend/product_picker
//= require spree/backend/option_value_picker
//= require spree/backend/taxons
//= require spree/backend/highlight_negative_numbers

/**
This is a collection of javascript functions and whatnot
under the spree namespace that do stuff we find helpful.
Hopefully, this will evolve into a propper class.
**/

Spree.ready(function() {
  // Highlight hovered table column
  $('table').on("mouseenter", 'td.actions a, td.actions button', function(){
    var tr = $(this).closest('tr');
    var klass = 'highlight action-' + $(this).data('action')
    tr.addClass(klass)

    var observer = new MutationObserver(function(mutations) {
      tr.removeClass(klass);
      this.disconnect();
    });
    observer.observe(tr.get(0), { childList: true });

    // Using .one() instead of .on() prevents multiple callbacks to be attached
    // to this event if mouseentered multiple times.
    $(this).one("mouseleave", function() {
      tr.removeClass(klass);
      observer.disconnect();
    });
  });
});


$.fn.visible = function(cond) { this[cond ? 'show' : 'hide' ]() };

// Apply to individual radio button that makes another element visible when checked
$.fn.radioControlsVisibilityOfElement = function(dependentElementSelector){
  if(!this.get(0)){ return  }
  var showValue = this.get(0).value;
  var radioGroup = $("input[name='" + this.get(0).name + "']");
  radioGroup.each(function(){
    $(this).click(function(){
      $(dependentElementSelector).visible(this.checked && this.value == showValue)
    });
    if(this.checked){ this.click() }
  });
}

Spree.ready(function(){
  var uniqueId = 1;
  $('.spree_add_fields').click(function() {
    var target = $(this).data("target");
    var new_table_row = $(target + ' tr:visible:last').clone();
    var new_id = new Date().getTime() + (uniqueId++);
    new_table_row.find("input, select").each(function () {
      var el = $(this);
      el.val("");
      // Replace last occurrence of a number
      el.prop("id", el.prop("id").replace(/\d+(?=[^\d]*$)/, new_id))
      el.prop("name", el.prop("name").replace(/\d+(?=[^\d]*$)/, new_id))
    })
    // When cloning a new row, set the href of all icons to be an empty "#"
    // This is so that clicking on them does not perform the actions for the
    // duplicated row
    new_table_row.find("a").each(function () {
      var el = $(this);
      el.prop('href', '#');
    })
    $(target).prepend(new_table_row);
  })

  $('body').on('click', '.delete-resource', function() {
    var el = $(this);
    if (confirm(el.data("confirm"))) {
      Spree.ajax({
        type: 'POST',
        url: $(this).prop("href"),
        data: {
          _method: 'delete',
        },
        dataType: 'script',
        success: function(response) {
          el.parents("tr").fadeOut('hide', function() {
            $(this).remove();
          });
        },
        error: function(response, textStatus, errorThrown) {
          show_flash('error', response.responseText);
        }
      });
    }
    return false;
  });

  $('body').on('click', 'a.spree_remove_fields', function() {
    var el = $(this);
    el.prev("input[type=hidden]").val("1");
    el.closest(".fields").hide();
    if (el.prop("href").substr(-1) == '#') {
      el.parents("tr").fadeOut('hide');
    }else if (el.prop("href")) {
      Spree.ajax({
        type: 'POST',
        url: el.prop("href"),
        data: {
          _method: 'delete',
        },
        success: function(response) {
          el.parents("tr").fadeOut('hide');
        },
        error: function(response, textStatus, errorThrown) {
          show_flash('error', response.responseText);
        }

      })
    }
    return false;
  });

  window.Spree.advanceOrder = function() {
    Spree.ajax({
      type: "PUT",
      async: false,
      data: {
        token: Spree.api_key
      },
      url: Spree.pathFor('api/checkouts/' + window.order_number + '/advance')
    }).done(function() {
      window.location.reload();
    });
  }
});
