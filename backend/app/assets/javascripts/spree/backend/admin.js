//= require_self
//= require spree/backend/handlebars_extensions
//= require spree/backend/variant_autocomplete
//= require spree/backend/taxon_autocomplete
//= require spree/backend/option_type_autocomplete
//= require spree/backend/user_picker
//= require spree/backend/product_picker
//= require spree/backend/option_value_picker
//= require spree/backend/taxons

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

var handle_date_picker_fields = function(){
  $('.datepicker').flatpickr({
    allowInput: true
  });

  // Handle range dates
  if ($('.date-range-filter .datepicker-from, .date-range-filter .datepicker-to').length) {
    // Returns a callback for flatpickr onChange event which updates the
    // respective range extremity flatpickr instance in order to have
    // the left range extremity lower or equal to the right range extremity.
    // This is accomplished swapping the range extremities when they are in the
    // wrong order.
    var swapDates = function($other, otherInstance, compareDates) {
      return function(selectedDates, dateStr, instance) {
        var date = instance.parseDate(dateStr);
        var otherDateStr = $other.val();
        var otherDate = instance.parseDate(otherDateStr);

        if (date && otherDate && compareDates(date, otherDate)) {
          instance.setDate(otherDate);
          otherInstance.setDate(date);
        }
      }
    }

    var $left = $('.date-range-filter .datepicker-from');
    var $right = $('.date-range-filter .datepicker-to');
    var leftInstance = $left[0]._flatpickr;
    var rightInstance = $right[0]._flatpickr;
    var leftSwapDates = swapDates($right, rightInstance, function(date, otherDate) {
      return date > otherDate
    })
    var rightSwapDates = swapDates($left, leftInstance, function(date, otherDate) {
      return date < otherDate
    })

    leftInstance.config.onChange.push(leftSwapDates);
    rightInstance.config.onChange.push(rightSwapDates);

    // Execute swap dates check in order to correct possible wrong order at page
    // load
    leftSwapDates(null, $left.val(), leftInstance);
  }
}

Spree.ready(function(){
  handle_date_picker_fields();
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

  // Fix sortable helper
  var fixHelper = function(e, ui) {
      ui.children().each(function() {
          $(this).width($(this).width());
      });
      return ui;
  };

  var td_count = $(this).find('tbody tr:first-child td').length
  $('table.sortable tbody').sortable({
    handle: '.handle',
    helper: fixHelper,
    placeholder: 'ui-sortable-placeholder',
    update: function(event, ui) {
      $("#progress").show();
      var tableEl = $(ui.item).closest("table.sortable")
      var positions = {};
      $.each(tableEl.find('tbody tr'), function(position, obj){
        var idAttr = $(obj).prop('id');
        if (idAttr) {
          var objId = idAttr.split('_').slice(-1);
          if (!isNaN(objId)) {
            positions['positions['+objId+']'] = position+1;
          }
        }
      });
      Spree.ajax({
        type: 'POST',
        dataType: 'script',
        url: tableEl.data("sortable-link"),
        data: positions,
        success: function(data){ $("#progress").hide(); }
      });
    },
    start: function (event, ui) {
      // Set correct height for placehoder (from dragged tr)
      ui.placeholder.height(ui.item.height())
      // Fix placeholder content to make it correct width
      ui.placeholder.html("<td colspan='"+(td_count-1)+"'></td><td class='actions'></td>")
    },
    stop: function (event, ui) {
      var tableEl = $(ui.item).closest("table.sortable")
      // Fix odd/even classes after reorder
      tableEl.find("tr:even").removeClass("odd even").addClass("even");
      tableEl.find("tr:odd").removeClass("odd even").addClass("odd");
    }
  });

  window.Spree.advanceOrder = function() {
    Spree.ajax({
      type: "PUT",
      async: false,
      data: {
        token: Spree.api_key
      },
      url: Spree.routes.checkouts_api + "/" + window.order_number + "/advance"
    }).done(function() {
      window.location.reload();
    });
  }
});
