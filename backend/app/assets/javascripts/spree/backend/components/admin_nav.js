Spree.ready(function() {
  var adminNavToggle = document.querySelector("#admin-nav-toggle");

  if (adminNavToggle) {
    adminNavToggle.addEventListener("click", function() {
      document.body.classList.toggle("admin-nav-hidden");
      console.log(document.cookie)
      document.cookie = "admin_nav_hidden=" + document.body.classList.contains("admin-nav-hidden") + "; expires=Fri, 31 Dec 9999 23:59:59 GMT"
    });
  }
});
