# frozen_string_literal: true

# @component "ui/forms/address"
class SolidusAdmin::UI::Forms::Address::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template(locals: { addressable: fake_address })
  end

  # @param disabled toggle
  def playground(disabled: false)
    render component("ui/forms/address").new(
      fieldset_name: "",
      addressable: fake_address,
      disabled:
    )
  end

  private

  def fake_address
    country = Spree::Country.find_or_initialize_by(iso: Spree::Config.default_country_iso)
    Spree::Address.new(country:)
  end
end
