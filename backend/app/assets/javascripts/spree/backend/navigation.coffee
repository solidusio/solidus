adjustNavigation = ->
  navHeight = $('.admin-nav-header').outerHeight() + $('.admin-nav-menu').outerHeight() + $('.admin-nav-footer').outerHeight()
  $('.admin-nav').toggleClass('fits', navHeight < $(window).height())

$ ->
  adjustNavigation()
  $(window).on('resize', adjustNavigation)
