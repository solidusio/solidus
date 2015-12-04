$ ->
  Spree.addImageHandlers = ->
    thumbnails = ($ '#product-images ul.thumbnails')
    ($ '#main-image').data 'selectedThumb', ($ '#main-image img').attr('src')
    thumbnails.find('li').eq(0).addClass 'selected'
    thumbnails.find('a').on 'click', (event) ->
      ($ '#main-image').data 'selectedThumb', ($ event.currentTarget).attr('href')
      ($ '#main-image').data 'selectedThumbId', ($ event.currentTarget).parent().attr('id')
      thumbnails.find('li').removeClass 'selected'
      ($ event.currentTarget).parent('li').addClass 'selected'
      false

    thumbnails.find('li').on 'mouseenter', (event) ->
      ($ '#main-image img').attr 'src', ($ event.currentTarget).find('a').attr('href')

    thumbnails.find('li').on 'mouseleave', (event) ->
      ($ '#main-image img').attr 'src', ($ '#main-image').data('selectedThumb')

  Spree.showVariantImages = (variantId) ->
    ($ 'li.vtmb').hide()
    ($ 'li.vtmb').each((index, li) =>
      $li = $(li)
      variantIds = $li.data('variant-ids')
      $li.show() if variantIds.indexOf(variantId) isnt -1
    )
    thumb = ($ '#product-images ul.thumbnails li:visible.vtmb').eq(0)
    thumb = ($ '#product-images ul.thumbnails li:visible').eq(0) unless thumb.length > 0
    ($ '#product-images ul.thumbnails li').removeClass 'selected'
    thumb.addClass 'selected'
    ($ '#main-image img').attr 'src', thumb.find('a').attr('href')

  Spree.updateVariantPrice = (variant) ->
    variantPrice = variant.data('price')
    ($ '.price.selling').text(variantPrice) if variantPrice
  radios = ($ '#product-variants input[type="radio"]')

  Spree.addImageHandlers()

  if radios.length > 0
    selectedRadio = ($ '#product-variants input[type="radio"][checked="checked"]')
    Spree.showVariantImages selectedRadio.attr('value')
    Spree.updateVariantPrice selectedRadio

  radios.click (event) ->
    Spree.showVariantImages @value
    Spree.updateVariantPrice ($ this)
