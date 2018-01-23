//= require 'solidus_admin/Sortable'

Handlebars.registerHelper('isRootTaxon', function() {
  return this.parent_id == null;
});

var TaxonTreeView = Backbone.View.extend({
  create_taxon: function(attributes) {
    Spree.ajax({
      type: "POST",
      dataType: "json",
      url: this.model.url() + "/taxons",
      data: {
        taxon: attributes
      },
      complete: this.redraw_tree
    });
  },

  update_taxon: function(id, attributes) {
    Spree.ajax({
      type: "PUT",
      dataType: "json",
      url: this.model.url() + "/taxons/" + id,
      data: {
        taxon: attributes
      },
      error: this.redraw_tree
    });
  },

  delete_taxon: function(id) {
    Spree.ajax({
      type: "DELETE",
      dataType: "json",
      url: this.model.url() + "/taxons/" + id,
      error: this.redraw_tree
    });
  },

  render: function() {
    var taxons_template = HandlebarsTemplates["taxons/tree"];
    this.$el.html(taxons_template({
      taxons: [this.model.get("root")]
    }));

    var sortableOptions = {
      group: {
        name: this.cid,
        pull: true,
        put: true
      },
      forceFallback: true,
      onEnd: this.handle_move.bind(this)
    };

    var lists = this.$('ul');
    for(var i = 0; i < lists.length; i++) {
      new Sortable(lists[i], sortableOptions);
    }
  },

  redraw_tree: function() {
    this.model.fetch({
      url: this.model.url() + '?set=nested'
    });
  },

  handle_move: function(e) {
    var el = $(e.item);
    this.update_taxon(el.data('taxon-id'), {
      parent_id: el.parent().closest('li').data('taxon-id'),
      child_index: el.index()
    });
  },

  handle_delete: function(e) {
    var el;
    el = $(e.target).closest('li');
    if (confirm(Spree.translations.are_you_sure_delete)) {
      this.delete_taxon(el.data('taxon-id'));
      el.remove();
    }
  },

  handle_add_child: function(e) {
    var el = $(e.target).closest('li');
    var parent_id = el.data('taxon-id');
    this.create_taxon({name: 'New node', parent_id: parent_id, child_index: 0});
  },

  handle_create: function(e) {
    e.preventDefault();
    var parent_id = this.model.get("root").id;
    this.create_taxon({name: 'New node', parent_id: parent_id, child_index: 0});
  },

  events: {
    'click .js-taxon-delete': 'handle_delete',
    'click .js-taxon-add-child': 'handle_add_child'
  },

  initialize: function() {
    _.bindAll(this, 'redraw_tree', 'handle_create');
    $('.add-taxon-button').on('click', this.handle_create);
    this.listenTo(this.model, 'sync', this.render);
    this.redraw_tree();
  }
});

Spree.ready(function() {
  if ($('#taxonomy_tree').length) {
    var model = new Spree.Models.Taxonomy({
      id: $('#taxonomy_tree').data("taxonomy-id")
    });
    new TaxonTreeView({
      el: $('#taxonomy_tree'),
      model: model
    });
  }
});
