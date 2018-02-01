class Tabs
  constructor: (@el) ->
    @$tabList = $(@el)
    @$tabs = @$tabList.find("li:not(.tabs-dropdown)")
    @tabs = @$tabs.toArray()
    @$tabList.append("<li class='tabs-dropdown'><a href='#'></a><ul></ul></li>")
    @$dropdown = @$tabList.find(".tabs-dropdown")

    @tabWidths = @tabs.map (tab) ->
      tab.offsetWidth
    @totalTabsWidth = @tabWidths.reduce (previousValue, currentValue) ->
      previousValue + currentValue
    @dropdownWidth = @$dropdown[0].offsetWidth

    $(window).on "resize", @overflowTabs
    @overflowTabs()

  overflowTabs: =>
    containerWidth = @$tabList[0].offsetWidth
    dropdownActive = @$dropdown.find("li").length

    for tab in @tabs
      $(tab).remove()

    remainingWidth = containerWidth

    if @totalTabsWidth < containerWidth
      # everything fits
      @$tabList.removeClass("tabs-overflowed")
    else
      @$tabList.addClass("tabs-overflowed")
      remainingWidth -= @dropdownWidth

    for tab, i in @tabs.slice()
      remainingWidth -= @tabWidths[i]

      if remainingWidth >= 0
        $(tab).insertBefore(@$dropdown).removeClass("in-dropdown")
      else
        $(tab).appendTo(@$dropdown.find("ul")).addClass("in-dropdown")

window.onload = ->
  new Tabs(el) for el in $(".tabs")
