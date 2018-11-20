Spree.ready(function() {
  if (JSON.parse(sessionStorage.getItem("navExtended"))) {
    document.body.classList.add("admin-nav-hidden");
  }

  var adminNavToggle = document.querySelector("#admin-nav-toggle");

  if (adminNavToggle) {
    adminNavToggle.addEventListener("click", function() {
      document.body.classList.toggle("admin-nav-hidden");
      sessionStorage.setItem("navExtended", document.body.classList.contains("admin-nav-hidden"));
    });
  }
});
