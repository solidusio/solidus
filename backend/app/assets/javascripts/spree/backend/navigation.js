Spree.ready(function() {
  var navHeight = function() {
    return $('.admin-nav-header').outerHeight() + $('.admin-nav-menu').outerHeight() + $('.admin-nav-footer').outerHeight();
  };

  var initStickyNavbar = function() {
    $(".admin-nav-sticky, .admin-nav").stick_in_parent();
  };

  var detachStickyNavbar = function() {
    $(".admin-nav-sticky, .admin-nav").trigger("sticky_kit:detach");
  };

  var checkSideBarFit = function() {
    var fits = navHeight() < $(window).height();

    $('.admin-nav').toggleClass('fits', fits);

    fits ? initStickyNavbar() : detachStickyNavbar();
  };

  checkSideBarFit();
  $(window).on('resize', checkSideBarFit);
});
