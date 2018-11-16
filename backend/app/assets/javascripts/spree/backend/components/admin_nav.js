Spree.ready(function() {
  var adminNavToggle = document.querySelector("#admin-nav-toggle");
  var adminNav =  document.querySelector(".admin-nav");

  function showNav() {
    adminNavToggle.innerHTML = '<i class=\"fa fa-chevron-left fa-2x\">';
    adminNav.style.display = "block";
  }

  function hideNav() {
    adminNavToggle.innerHTML = '<i class=\"fa fa-chevron-right fa-2x\">';
    adminNav.style.display = "none";
  }

  if (adminNavToggle) {
    adminNavToggle.addEventListener("click", function() {
      if (document.body.classList.contains("admin-nav-extended")) {
        showNav();
      } else {
        hideNav();
      }
      document.body.classList.toggle("admin-nav-extended");
    });
  }
});
