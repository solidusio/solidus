# frozen_string_literal: true

class SolidusAdmin::Stores::Form::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(store:, id:, url:)
    @store = store
    @id = id
    @url = url
  end

  def address
    @store.address || Spree::Address.new(country: Spree::Country.find_by(iso: Spree::Config.default_country_iso))
  end

  def address_excludes
    excludes = [:email, :street_contd]
    excludes << :phone unless Spree::Config.address_requires_phone
    excludes
  end

  def available_locales
    Spree.i18n_available_locales.map do |locale|
      [I18n.t("spree.i18n.this_file_language", locale: locale, default: locale.to_s, fallback: false), locale]
    end.sort
  end
end
