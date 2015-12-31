# variant autocompletion
$(document).ready ->
  window.variantTemplate = HandlebarsTemplates["variants/autocomplete"]
  window.variantStockTemplate = HandlebarsTemplates["variants/autocomplete_stock"]
  window.variantLineItemTemplate = HandlebarsTemplates["variants/line_items_autocomplete_stock"]

formatVariantResult = (variant) ->
  variant.image = variant.images[0].mini_url  if variant["images"][0] isnt `undefined` and variant["images"][0].mini_url isnt `undefined`
  variantTemplate variant: variant

$.fn.variantAutocomplete = (searchOptions = {}) ->
  @select2
    placeholder: Spree.translations.variant_placeholder
    minimumInputLength: 3
    initSelection: (element, callback) ->
      Spree.ajax
        url: Spree.routes.variants_api + "/" + element.val()
        success: callback
    ajax:
      url: Spree.routes.variants_api
      datatype: "json"
      quietMillis: 500
      params: { "headers": { "X-Spree-Token": Spree.api_key } }
      data: (term, page) =>
        searchData =
          q:
            product_name_or_sku_cont: term
          token: Spree.api_key
        _.extend(searchData, searchOptions)

      results: (data, page) ->
        window.variants = data["variants"]
        results: data["variants"]

    formatResult: formatVariantResult
    formatSelection: (variant) ->
      if !!variant.options_text
        variant.name + " (#{variant.options_text})"
      else
        variant.name
