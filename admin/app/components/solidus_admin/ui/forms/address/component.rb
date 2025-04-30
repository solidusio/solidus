# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Address::Component < SolidusAdmin::BaseComponent
  DEFAULT_FIELDS = %i[
    street
    street_contd
    city
    zipcode
    country_and_state
    phone
    email
  ].freeze

  FIELDS_PRESETS = {
    contact: DEFAULT_FIELDS + %i[name vat_id reverse_charge_status],
    location: DEFAULT_FIELDS,
  }.freeze

  renders_one :name, -> do
    component("ui/forms/field").text_field(@form_field_name, :name, object: @addressable)
  end

  renders_one :street, -> do
    component("ui/forms/field").text_field(@form_field_name, :address1, object: @addressable)
  end

  renders_one :street_contd, -> do
    component("ui/forms/field").text_field(@form_field_name, :address2, object: @addressable)
  end

  renders_one :city, -> do
    component("ui/forms/field").text_field(@form_field_name, :city, object: @addressable)
  end

  renders_one :zipcode, -> do
    component("ui/forms/field").text_field(@form_field_name, :zipcode, object: @addressable)
  end

  renders_one :country_and_state, SolidusAdmin::UI::Forms::Address::CountryAndState::Component
  renders_one :phone, -> do
    component("ui/forms/field").text_field(@form_field_name, :phone, object: @addressable)
  end

  renders_one :email, -> do
    component("ui/forms/field").text_field(@form_field_name, :email, object: @addressable)
  end

  renders_one :vat_id, -> do
    component("ui/forms/field").text_field(@form_field_name, :vat_id, object: @addressable)
  end

  renders_one :reverse_charge_status, -> do
    component("ui/forms/field").select(
      @form_field_name,
      :reverse_charge_status,
      Spree::Address.reverse_charge_statuses.keys.map { |key| [I18n.t("spree.reverse_charge_statuses.#{key}"), key] },
      object: @addressable
    )
  end

  # @param fields_preset [Symbol] decides which set of fields to render, accepted values: [:contact, :location]
  # @param include_fields [Symbol] optionally include fields that are not present in default/chosen field preset
  # @param exclude_fields [Symbol] optionally exclude fields that are present in default/chosen field preset
  def initialize(addressable:, form_field_name:, disabled: false, fields_preset: :contact, include_fields: [], exclude_fields: [])
    @addressable = addressable
    @form_field_name = form_field_name
    @disabled = disabled

    fields = FIELDS_PRESETS[fields_preset] || []
    fields = (fields + Array.wrap(include_fields.map(&:to_sym)) - Array.wrap(exclude_fields.map(&:to_sym))).uniq

    with_name if fields.include?(:name)
    with_street if fields.include?(:street)
    with_street_contd if fields.include?(:street_contd)
    with_city if fields.include?(:city)
    with_zipcode if fields.include?(:zipcode)
    with_country_and_state(addressable:, form_field_name:) if fields.include?(:country_and_state)
    with_phone if fields.include?(:phone)
    with_email if fields.include?(:email)
    with_vat_id if fields.include?(:vat_id)
    with_reverse_charge_status if fields.include?(:reverse_charge_status)
  end
end
