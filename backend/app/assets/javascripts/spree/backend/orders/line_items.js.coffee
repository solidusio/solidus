#= require spree/backend/models

Spree.CartLineItemView = Backbone.View.extend
  tagName: 'tr'
  className: 'line-item'

  initialize: (options) ->
    this.listenTo(@model, "change", @render)
    @editing = options.editing || @model.isNew()

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
    if @model.isNew()
      @remove()
      @model.destroy()
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
      noCancel: @model.isNew() && @model.collection.length == 1
    )
    el = @$el.html(html)
    @$("[name=variant_id]").variantAutocomplete({ in_stock_only: true })

Spree.CartLineItemTableView = Backbone.View.extend
  initialize: ->
    this.listenTo(this.collection, 'add', this.add)

  add: (line_item) ->
    view = new Spree.CartLineItemView(model: line_item)
    view.render()
    @$el.append(view.el)

Spree.CartAddLineItemButtonView = Backbone.View.extend
  initialize: ->
    this.listenTo(this.collection, 'update', this.render)
    this.render()

  events:
    "click": "onClick"

  onClick: ->
    this.collection.push({})

  render: ->
    @$el.prop("disabled", !this.collection.length || this.collection.some( (item) -> item.isNew() ))

$ ->
  if $("table.line-items").length
    order = new Spree.Models.Order({number: order_number})
    collection = order.get("line_items")

    new Spree.CartLineItemTableView
      el: $("table.line-items > tbody")
      collection: collection

    new Spree.CartAddLineItemButtonView
      el: $('.js-add-line-item')
      collection: collection

    order.fetch
      success: ->
        if !collection.length
          collection.push({})
