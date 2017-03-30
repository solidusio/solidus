NavigationView = Backbone.View.extend
  initialize: ->
    @$menuToggler       = $('.js-menu-button')
    @stateChangedByUser = false
    @isMenuOpen         = @isOpenOnCurrentWidth()

    $(window).on('resize', @onResize.bind(@))
    @render()

  remove: ->
    $(window).off('resize', @onResize)
    @$el.remove()
    @

  events:
    'click .js-toggle-menu': 'onChange'

  render: ->
    $('.admin-nav').toggleClass('fits', @navHeight() < $(window).height())
    @$menuToggler.prop('checked', @isMenuOpen).change()
    @

  navHeight: ->
    $('.admin-nav-header').outerHeight() +
    $('.admin-nav-menu').outerHeight() +
    $('.admin-nav-footer').outerHeight()

  isOpenOnCurrentWidth: ->
    $(window).width() > 767

  onChange: (event) ->
    @stateChangedByUser = true
    @isMenuOpen = @$menuToggler.prop('checked')
    @render()

  onResize: ->
    return if @stateChangedByUser
    @isMenuOpen = @isOpenOnCurrentWidth()
    @render()

$ ->
  new NavigationView(el: $('.admin'))
