'use strict';

Spree.ready(function(){
  flatpickr.localize({
    weekdays: {
      shorthand: Spree.t('abbr_day_names')
    },
    months: {
      longhand: Spree.t('month_names')
    }
  });

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
});
