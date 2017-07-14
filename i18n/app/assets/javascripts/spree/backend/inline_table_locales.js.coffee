Spree.InlineTableLocales = Backbone.View.extend(
  initialize: ->
    for store in @collection
      row = $("<tr id='store-id-#{store.id}'/>")
      @$el.append(row)
      new Spree.EditInlineLocales({
        el: row
        model: store
      });
)
