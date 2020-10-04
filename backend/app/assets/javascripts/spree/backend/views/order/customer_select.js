Spree.Views.Order.CustomerSelect = Backbone.View.extend({
  initialize: function() {
    this.render();
  },

  events: {
    "select2-selecting": "onSelect"
  },

  onSelect: function(e) {
    var customer = e.choice;
    this.trigger("select", customer)
  },

  render: function() {
    var customerTemplate = HandlebarsTemplates['orders/customer_details/autocomplete'];

    var formatCustomerResult = function(customer) {
      return customerTemplate({
        customer: customer,
        bill_address: customer.bill_address,
        ship_address: customer.ship_address
      })
    }

    this.$el.select2({
      placeholder: Spree.translations.choose_a_customer,
      ajax: {
        url: Spree.pathFor('api/users'),
        params: { "headers": {  'Authorization': 'Bearer ' + Spree.api_key } },
        datatype: 'json',
        data: function(term, page) {
          return {
            q: {
              m: 'or',
              email_start: term,
              firstname_or_lastname_start: term
            }
          }
        },
        results: function(data, page) {
          return {
            results: data.users,
            more: data.current_page < data.pages
          }
        }
      },
      formatResult: formatCustomerResult,
      formatSelection: function (customer) {
        return Select2.util.escapeMarkup(customer.email);
      }
    })
  }
});
