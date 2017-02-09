
Spree.CartLineItemView = Backbone.View.extend
  tagName: 'tr'
  className: 'line-item'

  initialize: (options) ->
    @editing = options.editing || false

  events:
    'click .edit-line-item': 'onEdit'
    'click .cancel-line-item': 'onCancel'
    'click .save-line-item': 'onSave'
    'click .delete-line-item': 'onDelete'

  onEdit: (e) ->
    e.preventDefault()
    @editing = true
    @render()

  onCancel: (e) ->
    e.preventDefault()
    @editing = false
    @render()

  onSave: (e) ->
    e.preventDefault()
    quantity = parseInt(@$('input.line_item_quantity').val())
    @model.save {quantity: quantity},
      patch: true,
      success: =>
        window.Spree.advanceOrder()
    @editing = false
    @render()

  onDelete: (e) ->
    e.preventDefault()
    return unless confirm(Spree.translations.are_you_sure_delete)
    @remove()
    @model.destroy
      success: =>
        window.Spree.advanceOrder()

  render: ->
    line_item = @model.attributes
    image = line_item.variant.images[0]
    html = HandlebarsTemplates['orders/line_item'](line_item: line_item, image: image)
    el = @$el.html(html)
    @$el.toggleClass('editing', @editing)

$ ->
  if $("table.line-items").length
    url = Spree.routes.orders_api + "/" + order_number
    Spree.ajax(url: url).done (result) ->
      lineItemModel = Backbone.Model.extend
        urlRoot: Spree.routes.line_items_api(order_number)

      for line_item in result.line_items
        model = new lineItemModel(line_item)
        view = new Spree.CartLineItemView(
          model: model
        )
        view.render()
        $("table.line-items > tbody").append(view.el)
