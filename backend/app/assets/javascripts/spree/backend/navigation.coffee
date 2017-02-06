navHeight = ->
  $('.admin-nav-header').outerHeight() + $('.admin-nav-menu').outerHeight() + $('.admin-nav-footer').outerHeight()

checkSideBarFit = ->
  $('.admin-nav').toggleClass('fits', navHeight() < $(window).height())

checkSticky = ->
  stickyElements = $('.admin-nav-sticky, .admin-nav')

  if $(window).width() <= 768
    stickyElements.trigger 'sticky_kit:detach'
  else
    stickyElements.stick_in_parent(spacer: false)

adjustNavigation = ->
  checkSideBarFit()
  checkSticky()

$ ->
  adjustNavigation()
  $(window).on('resize', adjustNavigation)
