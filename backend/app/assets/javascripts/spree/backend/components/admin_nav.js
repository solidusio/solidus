Spree.ready(function() {
  toggleTooltips()
  if(window.screen.width <= 1024 && !document.cookie.includes("admin_nav_hidden")){
    //Set default nav to collapse on small screens - but don't override user preference
    document.body.classList.add("admin-nav-hidden");
    document.cookie = "admin_nav_hidden=true; expires=Fri, 31 Dec 9999 23:59:59 GMT"
  }

  var adminNavToggle = document.querySelector("#admin-nav-toggle");

  if (adminNavToggle) {
    adminNavToggle.addEventListener("click", function() {
      document.body.classList.toggle("admin-nav-hidden");
      toggleTooltips();
      document.cookie = "admin_nav_hidden=" + document.body.classList.contains("admin-nav-hidden") + "; expires=Fri, 31 Dec 9999 23:59:59 GMT"
    });
  }

  function toggleTooltips(){
    $(".tab-with-icon .text:visible").each(function(){
      $(this.closest(".tab-with-icon")).attr("data-original-title","").tooltip()
    })
    $(".tab-with-icon .text:hidden").each(function(){
      $(this.closest(".tab-with-icon")).attr("data-original-title",$(this).text()).tooltip()
    })
  }

});
