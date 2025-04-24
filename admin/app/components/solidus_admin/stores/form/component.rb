# frozen_string_literal: true

class SolidusAdmin::Stores::Form::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(store:, id:, url:)
    @store = store
    @id = id
    @url = url
  end

  def available_locales
    Spree.i18n_available_locales.map do |locale|
      [I18n.t('spree.i18n.this_file_language', locale: locale, default: locale.to_s, fallback: false), locale]
    end.sort
  end
end
