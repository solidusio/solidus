navHeight = ->
  $('.admin-nav-header').outerHeight() + $('.admin-nav-menu').outerHeight() + $('.admin-nav-footer').outerHeight()

checkSideBarFit = ->
  $('.admin-nav').toggleClass('fits', navHeight() < $(window).height())

$ ->
  $(".admin-nav-sticky, .admin-nav").stick_in_parent()
  checkSideBarFit()
  $(window).on('resize', checkSideBarFit)
