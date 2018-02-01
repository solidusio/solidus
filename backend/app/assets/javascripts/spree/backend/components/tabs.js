/* global Tabs */

Tabs = (function() {
  function Tabs(el) {
    _.bindAll(this, 'overflowTabs');

    this.el = el;
    this.overflowTabs = this.overflowTabs.bind(this);
    this.$tabList = $(this.el);
    this.$tabs = this.$tabList.find("li:not(.tabs-dropdown)");
    this.tabs = this.$tabs.toArray();
    this.$tabList.append("<li class='tabs-dropdown'><a href='#'></a><ul></ul></li>");
    this.$dropdown = this.$tabList.find(".tabs-dropdown");

    this.tabWidths = this.tabs.map(function(tab) {
      return tab.offsetWidth;
    });
    this.totalTabsWidth = this.tabWidths.reduce(function(previousValue, currentValue) {
      return previousValue + currentValue;
    });
    this.dropdownWidth = this.$dropdown[0].offsetWidth;

    $(window).on("resize", this.overflowTabs);
    this.overflowTabs();
  }

  Tabs.prototype.overflowTabs = function() {
    var containerWidth = this.$tabList[0].offsetWidth;
    var dropdownActive = this.$dropdown.find("li").length;

    for (var i = 0; i < this.tabs.length; i++) {
      $(this.tabs[i]).remove();
    }

    if (this.totalTabsWidth < containerWidth) {
      this.$tabList.removeClass("tabs-overflowed");
    } else {
      this.$tabList.addClass("tabs-overflowed");
      remainingWidth -= this.dropdownWidth;
    }

    var remainingWidth = containerWidth;
    for (var i = 0; i < this.tabs.length; i++) {
      remainingWidth -= this.tabWidths[i];
      if (remainingWidth >= 0) {
        $(this.tabs[i]).insertBefore(this.$dropdown).removeClass("in-dropdown");
      } else {
        $(this.tabs[i]).appendTo(this.$dropdown.find("ul")).addClass("in-dropdown");
      }
    }
  };

  return Tabs;
})();

window.onload = function() {
  $(".tabs").each(function() {
    new Tabs(this);
  });
};
