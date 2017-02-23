#= require spree/backend/models

Spree.CartLineItemView = Backbone.View.extend
  tagName: 'tr'
  className: 'line-item'

  initialize: (options) ->
    this.listenTo(@model, "change", @render)
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
    order = new Spree.Models.Order({number: order_number})

    add_button = $('.js-add-line-item')
    add_button.click ->
      add_button.prop("disabled", true)
      model = lineItems.push({})
      view = new Spree.CartLineItemView(model: model)
      view.render()
      view.on('cancel', (event) -> add_button.prop("disabled", false))
      $("table.line-items > tbody").append(view.el)

    url = Spree.routes.orders_api + "/" + order_number
    order.fetch
      success: ->
        lineItems = order.get("line_items")
        lineItems.each (line_item) ->
          view = new Spree.CartLineItemView(model: line_item)
          view.render()
          $("table.line-items > tbody").append(view.el)

        add_button.prop("disabled", !lineItems.length)
        if !lineItems.length
          model = lineItems.push({})
          view = new Spree.CartLineItemView(model: model, noCancel: true)
          view.render()
          $("table.line-items > tbody").append(view.el)
