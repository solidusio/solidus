# variant autocompletion

variantTemplate = HandlebarsTemplates["variants/autocomplete"]

formatVariantResult = (variant) ->
  return variant.text if variant.loading
  variant.image = variant.images[0].mini_url  if variant["images"][0] isnt `undefined` and variant["images"][0].mini_url isnt `undefined`
  variantTemplate variant: variant

$.fn.variantAutocomplete = (searchOptions = {}) ->
  @select2
    placeholder: Spree.translations.variant_placeholder
    minimumInputLength: 3
    escapeMarkup: (markup) -> markup
    templateResult: formatVariantResult
    ajax:
      url: Spree.routes.variants_api
      datatype: "json"
      delay: 500
      data: (params) ->
        searchData =
          q:
            product_name_or_sku_cont: params.term
          token: Spree.api_key
        _.extend(searchData, searchOptions)
      processResults: (data, params) ->
        window.variants = data["variants"]
        results: data["variants"]
    templateSelection: (variant) ->
      if variant.name?
        if !!variant.options_text
          "#{variant.name} (#{variant.options_text})"
        else
          variant.name
      else
        variant.text
