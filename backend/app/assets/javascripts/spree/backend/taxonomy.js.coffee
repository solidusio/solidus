taxons_template = null

get_taxonomy = ->
  Spree.ajax
    url: "#{Spree.routes.taxonomy_path}?set=nested"

create_taxon = ({name, parent_id, child_index}) ->
  Spree.ajax
    type: "POST",
    dataType: "json",
    url: Spree.routes.taxonomy_taxons_path,
    data:
      taxon: {name, parent_id, child_index}
    complete: redraw_tree

update_taxon = ({id, parent_id, child_index}) ->
  Spree.ajax
    type: "PUT"
    dataType: "json"
    url: "#{Spree.routes.taxonomy_taxons_path}/#{id}"
    data:
      taxon: {parent_id, child_index}
    error: redraw_tree

delete_taxon = ({id}) ->
  Spree.ajax
    type: "DELETE"
    dataType: "json"
    url: "#{Spree.routes.taxonomy_taxons_path}/#{id}"
    error: redraw_tree

draw_tree = (taxonomy) ->
  $('#taxonomy_tree')
    .html( taxons_template({ taxons: [taxonomy.root] }) )
    .find('ul')
    .sortable
      connectWith: '#taxonomy_tree ul'
      placeholder: 'sortable-placeholder ui-state-highlight'
      tolerance: 'pointer'
      cursorAt: { left: 5 }

redraw_tree = ->
  get_taxonomy().done(draw_tree)

resize_placeholder = (ui) ->
  handleHeight = ui.helper.find('.sortable-handle').outerHeight()
  ui.placeholder.height(handleHeight)

restore_sort_targets = ->
  $('.ui-sortable-over').removeClass('ui-sortable-over')

highlight_sort_targets = (ui) ->
  restore_sort_targets()
  ui.placeholder.parents('ul').addClass('ui-sortable-over')

handle_move = (el) ->
  update_taxon
    id: el.data('taxon-id')
    parent_id: el.parent().closest('li').data('taxon-id')
    child_index: el.index()

handle_delete = (e) ->
  el = $(e.target).closest('li')
  if confirm(Spree.translations.are_you_sure_delete)
    delete_taxon({id: el.data('taxon-id')})
    el.remove()

get_create_handler = (taxonomy_id) ->
  handle_create = (e) ->
    e.preventDefault()
    name = 'New node'
    parent_id = taxonomy_id
    child_index = 0
    create_taxon({name, parent_id, child_index})

@setup_taxonomy_tree = (taxonomy_id) ->
  return unless taxonomy_id?
  taxons_template_text = $('#taxons-list-template').text()
  taxons_template = Handlebars.compile(taxons_template_text)
  Handlebars.registerPartial( 'taxons', taxons_template_text )
  redraw_tree()
  $('#taxonomy_tree').on
      sortstart: (e, ui) ->
        resize_placeholder(ui)
      sortover: (e, ui) ->
        highlight_sort_targets(ui)
      sortstop: restore_sort_targets
      sortupdate: (e, ui) ->
        handle_move(ui.item) unless ui.sender?
    .on('click', '.delete-taxon-button', handle_delete)
  $('.add-taxon-button').on('click', get_create_handler(taxonomy_id))
