Spree.ready(function(){
  if($('.js-zones-form').length) {
    var view = new Spree.Views.Zones.Form({
      el: $('.js-zones-form')
    });
    view.render()
  }
});
