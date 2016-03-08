class Tabs
  constructor: (@el) ->
    @$tabList = $(@el)
    @$tabs = @$tabList.find("li:not(.tabs-dropdown)")
    @tabs = @$tabs.toArray()
    @$tabList.append("<li class='tabs-dropdown'><a href='#'></a><ul></ul></li>")
    @$dropdown = @$tabList.find(".tabs-dropdown")
    @setWidths()
    @initEvents()

  initEvents: ->
    $(window).on "resize", @overflowTabs
    @overflowTabs()

  setWidths: ->
    @tabWidths = @tabs.map (tab) ->
      tab.offsetWidth
    @totalTabsWidth = @tabWidths.reduce (previousValue, currentValue) ->
      previousValue + currentValue

  overflowTabs: =>
    containerWidth = @$tabList[0].offsetWidth
    @lastKnownWidth = containerWidth unless @lastKnownWidth
    widthDifference = @totalTabsWidth - containerWidth
    widthDifferenceWithDropdown = widthDifference + @dropdownWidth()
    dropdownActive = @$dropdown.find("li").length

    if containerWidth <= @lastKnownWidth
      # The window is being sized down or we've just loaded the page
      if (dropdownActive and widthDifferenceWithDropdown > 0) or (not dropdownActive and widthDifference > 0)
        @hideTabsToFit(widthDifferenceWithDropdown)
    if containerWidth > @lastKnownWidth
      # The window is getting larger
      @showTabsToFit(widthDifference)

    @lastKnownWidth = containerWidth

  dropdownWidth: ->
    # If the dropdown isn't initiated we need to provide
    # our best guess of the size it will take up
    @$dropdown[0].offsetWidth or 50

  hideTabsToFit: (widthDifference) ->
    @$tabList.addClass("tabs-overflowed")
    tabs = @tabs.slice().reverse()

    for tab in tabs
      # Bail if things are now fitting
      return if widthDifference <= 0
      # Skip items already in the dropdown or active
      continue if $(tab).hasClass("in-dropdown") or $(tab).hasClass("active")

      tabWidth = tab.offsetWidth
      @totalTabsWidth -= tabWidth
      widthDifference -= tabWidth
      $(tab).appendTo(@$dropdown.find("ul")).addClass("in-dropdown")

  showTabsToFit: (widthDifference) ->
    for tab, i in @tabs.slice()
      # Skip items that aren't already in the dropdown
      continue unless $(tab).hasClass("in-dropdown")

      # Get our tab's width from the array
      # We can't measure it here because it's hidden in the dropdown
      tabWidth = @tabWidths[i]

      # Bail if there's no room for this tab
      break if widthDifference + tabWidth > 0

      @totalTabsWidth += tabWidth
      widthDifference += tabWidth
      $(tab).insertBefore(@$dropdown).removeClass("in-dropdown")

    # Reset styles if our dropdown is now empty
    if @$dropdown.find("li").length is 0
      @$tabList.removeClass("tabs-overflowed")

window.onload = ->
  new Tabs(el) for el in $(".tabs")
