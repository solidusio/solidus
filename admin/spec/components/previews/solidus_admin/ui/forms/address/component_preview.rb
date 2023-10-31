# frozen_string_literal: true

# @component "ui/forms/address"
class SolidusAdmin::UI::Forms::Address::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end

  # @param disabled toggle
  def playground(disabled: false)
    view = ActionView::Base.new(ActionView::LookupContext.new([]), {}, nil)
    render component("ui/forms/address").new(
      form: ActionView::Helpers::FormBuilder.new(:address, Spree::Address.new, view, {}),
      disabled: disabled
    )
  end
end
