Spree.InlineTableLocales = Backbone.View.extend(
  initialize: ->
    if @$el.length
      Spree.ajax({
        type: 'GET'
        url: "/api/config/available_locales"
        success: (collection) =>
          for store in collection
            row = $("<tr id='store-id-#{store.id}'/>")
            @$el.append(row)
            new Spree.EditInlineLocales({
              el: row
              model: store
            });
      })
)
