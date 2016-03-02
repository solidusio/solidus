# variant autocompletion

variantTemplate = HandlebarsTemplates["variants/autocomplete"]

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
    formatSelection: (variant, container, escapeMarkup) ->
      if !!variant.options_text
        Select2.util.escapeMarkup("#{variant.name} (#{variant.options_text}")
      else
        Select2.util.escapeMarkup(variant.name)
