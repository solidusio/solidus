Handlebars.registerHelper 'isRootTaxon', ->
  !@parent_id?

TaxonTreeView = Backbone.View.extend
  create_taxon: ({name, parent_id, child_index}) ->
    Spree.ajax
      type: "POST",
      dataType: "json",
      url: "#{this.model.url()}/taxons",
      data:
        taxon: {name, parent_id, child_index}
      complete: @redraw_tree

  update_taxon: ({id, parent_id, child_index}) ->
    Spree.ajax
      type: "PUT"
      dataType: "json"
      url: "#{this.model.url()}/taxons/#{id}",
      data:
        taxon: {parent_id, child_index}
      error: @redraw_tree

  delete_taxon: ({id}) ->
    Spree.ajax
      type: "DELETE"
      dataType: "json"
      url: "#{this.model.url()}/taxons/#{id}",
      error: @redraw_tree

  render: ->
    taxons_template = HandlebarsTemplates["taxons/tree"]
    this.$el
      .html( taxons_template({ taxons: [this.model.get("root")] }) )
      .find('ul')
      .sortable
        connectWith: '#taxonomy_tree ul'
        placeholder: 'sortable-placeholder ui-state-highlight'
        tolerance: 'pointer'
        cursorAt: { left: 5 }

  redraw_tree: ->
    this.model.fetch({
      url: this.model.url() + '?set=nested'
    })

  resize_placeholder: (e, ui) ->
    handleHeight = ui.helper.find('.taxon').outerHeight()
    ui.placeholder.height(handleHeight)

  restore_sort_targets: ->
    $('.ui-sortable-over').removeClass('ui-sortable-over')

  highlight_sort_targets: (e, ui) ->
    @restore_sort_targets()
    ui.placeholder.parents('ul').addClass('ui-sortable-over')

  handle_move: (e, ui) ->
    return if ui.sender?
    el = ui.item
    @update_taxon
      id: el.data('taxon-id')
      parent_id: el.parent().closest('li').data('taxon-id')
      child_index: el.index()

  handle_delete: (e) ->
    el = $(e.target).closest('li')
    if confirm(Spree.translations.are_you_sure_delete)
      @delete_taxon({id: el.data('taxon-id')})
      el.remove()

  handle_add_child: (e) ->
    el = $(e.target).closest('li')
    parent_id = el.data('taxon-id')
    name = 'New node'
    child_index = 0
    @create_taxon({name, parent_id, child_index})

  handle_create: (e) ->
    e.preventDefault()
    name = 'New node'
    parent_id = this.model.get("root").id
    child_index = 0
    @create_taxon({name, parent_id, child_index})

  events: {
    'sortstart': 'resize_placeholder',
    'sortover': 'highlight_sort_targets',
    'sortstop': 'restore_sort_targets',
    'sortupdate': 'handle_move',

    'click .js-taxon-delete': 'handle_delete',
    'click .js-taxon-add-child': 'handle_add_child',
  }

  initialize: ->
    _.bindAll(this, 'redraw_tree', 'handle_create')
    $('.add-taxon-button').on('click', @handle_create)

    this.listenTo(this.model, 'sync', this.render)

    @redraw_tree()

Spree.ready ->
  if $('#taxonomy_tree').length
    model = new Spree.Models.Taxonomy({id: $('#taxonomy_tree').data("taxonomy-id")})
    new TaxonTreeView
      el: $('#taxonomy_tree')
      model: model
