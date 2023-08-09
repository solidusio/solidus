/**
 * Select2 Armenian translation.
 *
 * @author  Arman Harutyunyan <armanx@gmail.com>
 * @author  Siruhi Karakhanyan <sirunkarakhanyan1983@gmail.com>
 *
 */
(function($) {
    "use strict";

    $.fn.select2.locales['hy'] = {
        formatNoMatches: function() {
            return "Համընկնումներ չեն գտնվել";
        },
        formatInputTooShort: function(input, min) {
            return "Խնդրում ենք մուտքագրել առնվազն" + character(min - input.length);
        },
        formatInputTooLong: function(input, max) {
            return "Խնդրում ենք մուտքագրել" + character(input.length - max) + " պակաս";
        },
        formatSelectionTooBig: function(limit) {
            return "Դուք կարող եք ընտրել ոչ ավելին" + character(limit);
        },
        formatLoadMore: function(pageNumber) {
            return "Տվյալների բեռնում…";
        },
        formatSearching: function() {
            return "Որոնել…";
        }
    };

    $.extend($.fn.select2.defaults, $.fn.select2.locales['hy']);

    function character(n) {
        return " " + n + " խորհրդանիշ";
    }
})(jQuery);
