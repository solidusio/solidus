
Spree.CartLineItemView = Backbone.View.extend
  tagName: 'tr'
  className: 'line-item'

  initialize: (options) ->
    @editing = options.editing || @model.isNew()
    @noCancel = options.noCancel

  events:
    'click .edit-line-item': 'onEdit'
    'click .cancel-line-item': 'onCancel'
    'click .save-line-item': 'onSave'
    'click .delete-line-item': 'onDelete'
    'change .js-select-variant': 'onChangeVariant'

  onEdit: (e) ->
    e.preventDefault()
    @editing = true
    @render()

  onCancel: (e) ->
    e.preventDefault()
    @trigger('cancel')
    if @model.isNew()
      @remove()
    else
      @editing = false
      @render()

  validate: () ->
    @$('[name=quantity]').toggleClass 'error', !@$('[name=quantity]').val()
    @$('.select2-container').toggleClass 'error', !@$('[name=variant_id]').val()

    !@$('.select2-container').hasClass('error') && !@$('[name=quantity]').hasClass('error')

  onSave: (e) ->
    e.preventDefault()
    return unless @validate()
    attrs = {
      quantity: parseInt(@$('input.line_item_quantity').val())
    }
    if @model.isNew()
      attrs['variant_id'] = @$("[name=variant_id]").val()
    @model.save attrs,
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
    image = line_item.variant && line_item.variant.images[0]
    html = HandlebarsTemplates['orders/line_item'](
      line_item: line_item,
      image: image,
      editing: @editing,
      isNew: @model.isNew(),
      noCancel: @noCancel
    )
    el = @$el.html(html)
    @$("[name=variant_id]").variantAutocomplete({ in_stock_only: true })

$ ->
  if $("table.line-items").length
    url = Spree.routes.orders_api + "/" + order_number
    lineItemModel = Backbone.Model.extend
      urlRoot: Spree.routes.line_items_api(order_number)

    add_button = $('.js-add-line-item')
    add_button.click ->
      add_button.prop("disabled", true)
      view = new Spree.CartLineItemView(model: new lineItemModel())
      view.render()
      view.on('cancel', (event) -> add_button.prop("disabled", false))
      $("table.line-items > tbody").append(view.el)

    Spree.ajax(url: url).done (result) ->
      for line_item in result.line_items
        model = new lineItemModel(line_item)
        view = new Spree.CartLineItemView(model: model)
        view.render()
        $("table.line-items > tbody").append(view.el)

      add_button.prop("disabled", !result.line_items.length)
      if !result.line_items.length
        view = new Spree.CartLineItemView(model: new lineItemModel(), noCancel: true)
        view.render()
        $("table.line-items > tbody").append(view.el)
