# frozen_string_literal: true

# @component "ui/forms/address"
class SolidusAdmin::UI::Forms::Address::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template(locals: { addressable: fake_address })
  end

  # @param disabled toggle
  # @param fields_preset select { choices: [contact, location] }
  # @param include_fields text "E.g. zipcode,street"
  # @param exclude_fields text "E.g. name,street_contd"
  def playground(disabled: false, fields_preset: :contact, include_fields: "", exclude_fields: "")
    render component("ui/forms/address").new(
      form_field_name: "",
      addressable: fake_address,
      disabled:,
      fields_preset:,
      include_fields: include_fields.present? ? include_fields.gsub(/\s+/, "").split(",") : [],
      exclude_fields: exclude_fields.present? ? exclude_fields.gsub(/\s+/, "").split(",") : [],
    )
  end

  private

  def fake_address
    country = Spree::Country.find_or_initialize_by(iso: Spree::Config.default_country_iso)
    Spree::Address.new(country:)
  end
end
