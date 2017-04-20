Handlebars.registerHelper 'isRootTaxon', ->
  !@parent_id?

TaxonTreeView = Backbone.View.extend
  get_taxonomy: ->
    Spree.ajax
      url: "#{Spree.routes.taxonomy_path}?set=nested"

  create_taxon: ({name, parent_id, child_index}) ->
    Spree.ajax
      type: "POST",
      dataType: "json",
      url: Spree.routes.taxonomy_taxons_path,
      data:
        taxon: {name, parent_id, child_index}
      complete: @redraw_tree

  update_taxon: ({id, parent_id, child_index}) ->
    Spree.ajax
      type: "PUT"
      dataType: "json"
      url: "#{Spree.routes.taxonomy_taxons_path}/#{id}"
      data:
        taxon: {parent_id, child_index}
      error: @redraw_tree

  delete_taxon: ({id}) ->
    Spree.ajax
      type: "DELETE"
      dataType: "json"
      url: "#{Spree.routes.taxonomy_taxons_path}/#{id}"
      error: @redraw_tree

  draw_tree: (taxonomy) ->
    taxons_template = HandlebarsTemplates["taxons/tree"]
    this.$el
      .html( taxons_template({ taxons: [taxonomy.root] }) )
      .find('ul')
      .sortable
        connectWith: '#taxonomy_tree ul'
        placeholder: 'sortable-placeholder ui-state-highlight'
        tolerance: 'pointer'
        cursorAt: { left: 5 }

  redraw_tree: ->
    @get_taxonomy().done(@draw_tree)

  resize_placeholder: (e, ui) ->
    handleHeight = ui.helper.find('.sortable-handle').outerHeight()
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
    @get_taxonomy().done (taxonomy) =>
      name = 'New node'
      parent_id = taxonomy.root.id
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

  initialize: ({taxonomy_id}) ->
    _.bindAll(this, 'redraw_tree', 'draw_tree', 'handle_create')
    $('.add-taxon-button').on('click', @handle_create)

    this.taxonomy_id = taxonomy_id
    @redraw_tree()

$ ->
  if $('#taxonomy_tree').length
    new TaxonTreeView
      el: $('#taxonomy_tree')
      taxonomy_id: $('#taxonomy_tree').data("taxonomy-id")
