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
      var $name, $address1, $address2, $city, $zipcode, $phone;

      beforeEach(function() {
        loadFixture("order/combined_name_address");
        loadView();

        $name = $el.find('[name$="[name]"]');
        $address1 = $el.find('[name$="[address1]"]');
        $address2 = $el.find('[name$="[address2]"]');
        $city = $el.find('[name$="[city]"]');
        $zipcode = $el.find('[name$="[zipcode]"]');
        $phone = $el.find('[name$="[phone]"]');
      });

      it("updates the name field on change", function() {
        model.set({ name: 'John Doe' });
        expect(model.get('name')).to.eq('John Doe');

        view.render();
        expect($name).to.have.$val('John Doe');
      });

      it("updates the address lines on change", function() {
        model.set({
          address1: '80697 Cole Parks',
          address2: 'Apt. 986',
          city: 'Keeblerfort',
          zipcode: '16804',
          phone: '1-744-701-0536 x30504'
        });

        view.render();
        expect($address1).to.have.$val('80697 Cole Parks');
        expect($address2).to.have.$val('Apt. 986');
        expect($city).to.have.$val('Keeblerfort');
        expect($zipcode).to.have.$val('16804');
        expect($phone).to.have.$val('1-744-701-0536 x30504');
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

      it("updates the name field on change", function() {
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
