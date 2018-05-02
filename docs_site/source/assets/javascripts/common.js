import "jquery";
import "popper.js";
// import "bootstrap";
import Headroom from "headroom.js";
import popover from "./vendor/popover";
import prism from "./vendor/prism";

$(function () {
  //Menu toggler functionality
  $(".site-menu-toggler").click(function () {
    $("body").toggleClass("menu-open");
    return false;
  });

  $(".site-navbar .backdrop").click(function () {
    $("body").removeClass("menu-open");
    return false;
  });

  //Site menu
  (function () {
    let $menuItems = $("#site-navbar > ul > li");

    $('#site-navbar .collapse').on('show.bs.collapse hide.bs.collapse', function (e) {
      $(this).closest("li").toggleClass("active", (e.type === "show"));
    });
  })();


  //Sticky header initialization
  let header = document.querySelector(".site-header");
  let navbar = document.querySelector(".navbar-content")
  let headroom  = new Headroom(header, {
    offset: header.offsetHeight,
    classes: {
      initial: "site-header",
      pinned: "site-header--pinned",
      unpinned: "site-header--unpinned",
      top: "site-header--top",
      bottom: "site-header--bottom",
      notTop: "site-header--not-top",
      notBottom: "site-header--scrolled"
    },
    onPin : function() { navbar.classList.toggle('pinned'); },
    onUnpin : function() { navbar.classList.toggle('pinned'); }
  });
  // initialise
  headroom.init();

  //Prevent invalid form submit
  $("body").on("submit", ".needs-validation", function (event) {
    if (this[0].checkValidity() === false) {
      event.preventDefault();
      event.stopPropagation();
    }
    $(this).addClass('was-validated');
  });

  //Show footnote tooltips
  $('.footnote[data-toggle="popover"]').popover({
    html:true,
    placement: "bottom",
    trigger: 'hover focus',
    //container: 'body',
    preventOverflow:{
      padding: 15
    }


  })
});
