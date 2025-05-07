# frozen_string_literal: true

# @component "ui/forms/address"
class SolidusAdmin::UI::Forms::Address::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  # @param fieldset [Symbol] select { choices: [contact, location] }
  def overview(fieldset: :contact)
    render_with_template(locals: { addressable: fake_address, fieldset: })
  end

  # @param fieldset [Symbol] select { choices: [contact, location] }
  def with_extended_fields(fieldset: :contact)
    render_with_template(locals: { addressable: fake_address, fieldset: })
  end

  def with_custom_fieldset
    addressable = Struct.new(:firstname, :lastname, :company, :vat_id) do
      def self.human_attribute_name(attribute)
        attribute.to_s.humanize
      end
    end.new

    render_with_template(locals: { addressable: })
  end

  # @param disabled toggle
  # @param fieldset [Symbol] select { choices: [contact, location] }
  # @param excludes select { choices: [name, street, street_contd, city_and_zipcode, country_and_state, phone, email, reverse_charge], multiple: true }
  def playground(disabled: false, fieldset: :contact, excludes: "")
    render component("ui/forms/address").new(
      form_field_name: "",
      addressable: fake_address,
      disabled:,
      fieldset:,
      excludes: excludes.present? ? excludes.split(",") : [],
    )
  end

  private

  def fake_address
    country = Spree::Country.find_or_initialize_by(iso: Spree::Config.default_country_iso)
    Spree::Address.new(country:)
  end
end
