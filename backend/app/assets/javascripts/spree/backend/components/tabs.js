/* global Tabs */
/* eslint no-redeclare: "off" */

Tabs = (function() {
  function Tabs(el) {
    _.bindAll(this, 'overflowTabs');

    this.el = el;
    this.tabs = this.el.querySelectorAll("li:not(.tabs-dropdown)")

    /* <li class='tabs-dropdown'><a href='#'></a><ul></ul></li> */
    this.dropdown = document.createElement('li');
    this.dropdown.classList.add('tabs-dropdown');
    this.dropdown.appendChild(document.createElement('a'));
    this.dropdownList = document.createElement('ul');
    this.dropdown.appendChild(this.dropdownList);

    this.el.appendChild(this.dropdown);

    this.tabWidths = _.map(this.tabs, function(tab) {
      return tab.offsetWidth;
    });
    this.totalTabsWidth = this.tabWidths.reduce(function(previousValue, currentValue) {
      return previousValue + currentValue;
    }, 0);

    window.addEventListener("resize", this.overflowTabs);
    this.overflowTabs();
  }

  Tabs.prototype.overflowTabs = function() {
    var containerWidth = this.el.offsetWidth;
    var dropdownWidth = this.dropdown.offsetWidth;

    for (var i = 0; i < this.tabs.length; i++) {
      var tab = this.tabs[i];
      tab.parentNode.removeChild(tab);
    }

    if (this.totalTabsWidth < containerWidth) {
      this.el.classList.remove("tabs-overflowed");
    } else {
      this.el.classList.add("tabs-overflowed");
      remainingWidth -= dropdownWidth;
    }

    var remainingWidth = containerWidth;
    for (var i = 0; i < this.tabs.length; i++) {
      remainingWidth -= this.tabWidths[i];
      var tab = this.tabs[i];
      if (remainingWidth >= 0) {
        tab.classList.remove("in-dropdown");
        this.el.insertBefore(tab, this.dropdown);
      } else {
        tab.classList.add("in-dropdown");
        this.dropdownList.appendChild(tab);
      }
    }
  };

  return Tabs;
})();

window.addEventListener('load', function() {
  _.each(document.querySelectorAll('.tabs'), function(el) {
    new Tabs(el);
  });
});
