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

jQuery(function($) {
  // Highlight hovered table column
  $('table').on("mouseenter", 'td.actions a, td.actions button', function(){
    var tr = $(this).closest('tr');
    var klass = 'highlight action-' + $(this).data('action')
    tr.addClass(klass)
    tr.prev().addClass('before-' + klass);
  });
  $('table').on("mouseleave", 'td.actions a, td.actions button', function(){
    var tr = $(this).closest('tr');
    var klass = 'highlight action-' + $(this).data('action')
    tr.removeClass(klass)
    tr.prev().removeClass('before-' + klass);
  });
});


$.fn.visible = function(cond) { this[cond ? 'show' : 'hide' ]() };

// Apply to individual radio button that makes another element visible when checked
$.fn.radioControlsVisibilityOfElement = function(dependentElementSelector){
  if(!this.get(0)){ return  }
  showValue = this.get(0).value;
  radioGroup = $("input[name='" + this.get(0).name + "']");
  radioGroup.each(function(){
    $(this).click(function(){
      $(dependentElementSelector).visible(this.checked && this.value == showValue)
    });
    if(this.checked){ this.click() }
  });
}

handle_date_picker_fields = function(){
  $('.datepicker').datepicker({
    dateFormat: Spree.translations.date_picker,
    dayNames: Spree.translations.abbr_day_names,
    dayNamesMin: Spree.translations.abbr_day_names,
    firstDay: Spree.translations.first_day,
    monthNames: Spree.translations.month_names,
    prevText: Spree.translations.previous,
    nextText: Spree.translations.next,
    showOn: "focus"
  });

  // Correctly display range dates
  $('.date-range-filter .datepicker-from').datepicker('option', 'onSelect', function(selectedDate) {
    $(".date-range-filter .datepicker-to" ).datepicker( "option", "minDate", selectedDate );
  });
  $('.date-range-filter .datepicker-to').datepicker('option', 'onSelect', function(selectedDate) {
    $(".date-range-filter .datepicker-from" ).datepicker( "option", "maxDate", selectedDate );
  });
}

$(document).ready(function(){
  handle_date_picker_fields();
  $(".observe_field").on('change', function() {
    target = $(this).data("update");
    $(target).hide();
    Spree.ajax({ dataType: 'html',
             url: $(this).data("base-url")+encodeURIComponent($(this).val()),
             type: 'get',
             success: function(data){
               $(target).html(data);
               $(target).show();
             }
    });
  });
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
    el = $(this);
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

  $('table.sortable').ready(function(){
    var td_count = $(this).find('tbody tr:first-child td').length
    $('table.sortable tbody').sortable(
      {
        handle: '.handle',
        helper: fixHelper,
        placeholder: 'ui-sortable-placeholder',
        update: function(event, ui) {
          $("#progress").show();
          tableEl = $(ui.item).closest("table.sortable")
          positions = {};
          $.each(tableEl.find('tbody tr'), function(position, obj){
            idAttr = $(obj).prop('id');
            if (idAttr) {
              objId = idAttr.split('_').slice(-1);
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
          tableEl = $(ui.item).closest("table.sortable")
          // Fix odd/even classes after reorder
          tableEl.find("tr:even").removeClass("odd even").addClass("even");
          tableEl.find("tr:odd").removeClass("odd even").addClass("odd");
        }

      });
  });

  window.Spree.advanceOrder = function() {
    Spree.ajax({
      type: "PUT",
      async: false,
      data: {
        token: Spree.api_key
      },
      url: Spree.routes.checkouts_api + "/" + order_number + "/advance"
    }).done(function() {
      window.location.reload();
    });
  }
});
