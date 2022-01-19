fixture.preload("order/combined_name_address", "order/separate_name_address");

describe("Spree.Views.Order.Address", function() {
  var model, view, $el;

  var loadFixture = function(path) {
    var fixtures = fixture.load(path, true);
    $el = $(fixtures[0]);
  }

  var loadView = function() {
    model = new Spree.Models.Address();
    view = new Spree.Views.Order.Address({
      model: model,
      el: $el,
    });
    view.render();
  }

  describe("will set name fields upon a model change", function() {
    describe("with combined firstname and lastname", function() {
      var $name;

      beforeEach(function() {
        loadFixture("order/combined_name_address");
        loadView();

        $name = $el.find('[name$="[name]"]');
      });

      it("sets the name field on change", function() {
        model.set({ name: 'John Doe' });
        expect(model.get('name')).to.eq('John Doe');

        view.render();
        expect($name).to.have.$val('John Doe');
      });
    });

    describe("with separate firstname and lastname", function() {
      var $firstname, $lastname;

      beforeEach(function() {
        loadFixture("order/separate_name_address");
        loadView();

        $firstname = $el.find('[name$="[firstname]"]');
        $lastname = $el.find('[name$="[lastname]"]');
      });

      it("sets the name field on change", function() {
        model.set({ firstname: 'John', lastname: 'Doe' });
        expect(model.get('firstname')).to.eq('John');
        expect(model.get('lastname')).to.eq('Doe');

        view.render();
        expect($firstname).to.have.$val('John');
        expect($lastname).to.have.$val('Doe');
      });
    });
  });
});
