/**
 * Select2 German translation
 */
(function ($) {
    "use strict";

    $.fn.select2.locales['de'] = {
        formatNoMatches: function () { return "Zadetkov iskanja ni bilo mogoče najti."; },
        formatInputTooShort: function (input, min) { var n = min - input.length; return "Prosim vpišite še " + n + " znak" + (limit === 1 ? "" : "e"); },
        formatInputTooLong: function (input, max) { var n = input.length - max; return "Prosim zbrišite " + n + " znak" + (limit === 1 ? "" : "ov"); },
        formatSelectionTooBig: function (limit) { return "Označite lahko največ " + limit + " predmet" + (limit === 1 ? "" : "e"); },
        formatLoadMore: function (pageNumber) { return "Nalagam več zadetkov…"; },
        formatSearching: function () { return "Iščem…"; },
        formatMatches: function (matches) { return matches + " zadet " + (matches > 1 ? "kov" : "ek") + " na voljo."; }
    };

    $.extend($.fn.select2.defaults, $.fn.select2.locales['sl-SI']);
})(jQuery);
