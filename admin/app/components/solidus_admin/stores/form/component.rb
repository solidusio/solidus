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

  # Only a saved attachment has a URL: after a failed save the form is shown
  # again with a new file assigned but not stored yet.
  def attachment_preview_url(name)
    return unless @store.persisted? && @store.errors.empty?
    return unless @store.public_send(:"#{name}_present?")

    @store.public_send(name).url
  end

  def available_locales
    Spree.i18n_available_locales.map do |locale|
      [I18n.t("spree.i18n.this_file_language", locale: locale, default: locale.to_s, fallback: false), locale]
    end.sort
  end
end
