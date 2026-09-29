# frozen_string_literal: true

# @component "ui/forms/select_taxons"
class SolidusAdmin::UI::Forms::SelectTaxons::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end
end
