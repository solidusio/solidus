Spree.ready(function() {
  if (window.screen.width <= 1024 && !document.cookie.includes("admin_nav_hidden")) {
    // Set default nav to collapse on small screens - but don't override user preference
    document.body.classList.add("admin-nav-hidden");
    document.cookie = "admin_nav_hidden=true; expires=Fri, 31 Dec 9999 23:59:59 GMT";
  }

  var adminNavToggle = document.querySelector("#admin-nav-toggle");

  if (adminNavToggle) {
    adminNavToggle.addEventListener("click", function(e) {
      e.preventDefault();
      document.body.classList.toggle("admin-nav-hidden");
      $(document.body).trigger("sticky_kit:recalc");
      adminNavToggle.classList.toggle("fa-chevron-circle-left");
      adminNavToggle.classList.toggle("fa-chevron-circle-right");
      document.cookie = "admin_nav_hidden=" + document.body.classList.contains("admin-nav-hidden") + "; expires=Fri, 31 Dec 9999 23:59:59 GMT";
    });
  }

  if (document.body.classList.contains('admin-nav-hidden')) {
    $(adminNavToggle).removeClass('fa-chevron-circle-left').addClass('fa-chevron-circle-right');
  }
});
