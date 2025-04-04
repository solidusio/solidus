# frozen_string_literal: true

class SolidusAdmin::Stores::Edit::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  # Define the necessary attributes for the component
  attr_reader :store, :available_countries

  # Initialize the component with required data
  def initialize(store:)
    @store = store
    @available_countries = fetch_available_countries
  end

  def form_id
    @form_id ||= "#{stimulus_id}--form-#{@store.id}"
  end

  def currency_options
    Spree::Config.available_currencies.map(&:iso_code)
  end

  # Generates options for cart tax countries
  def cart_tax_country_options
    fetch_available_countries(restrict_to_zone: Spree::Config[:checkout_zone]).map do |country|
      [country.name, country.iso]
    end
  end

  # Generates available locales
  def localization_options
    Spree.i18n_available_locales.map do |locale|
      [
        I18n.t('spree.i18n.this_file_language', locale: locale, default: locale.to_s),
        locale
      ]
    end
  end

  # Fetch countries for the address form
  def available_country_options
    Spree::Country.order(:name).map { |country| [country.name, country.id] }
  end

  private

  # Fetch the available countries for the localization section
  def fetch_available_countries(restrict_to_zone: Spree::Config[:checkout_zone])
    countries = Spree::Country.available(restrict_to_zone:)

    country_names = Carmen::Country.all.map do |country|
      [country.code, country.name]
    end.to_h

    country_names.update I18n.t('spree.country_names', default: {}).stringify_keys

    countries.collect do |country|
      country.name = country_names.fetch(country.iso, country.name)
      country
    end.sort_by { |country| country.name.parameterize }
  end
end
