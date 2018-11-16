Spree.ready(function() {
  var adminNavToggle = document.querySelector("#admin-nav-toggle");

  if (adminNavToggle) {
    adminNavToggle.addEventListener("click", function() {
      document.body.classList.toggle("admin-nav-extended");
    });
  }
});
