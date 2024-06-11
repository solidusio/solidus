# frozen_string_literal: true

# @component "ui/toast"
class SolidusAdmin::UI::Toast::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end

  # @param scheme select { choices: [default, error] }
  # @param text text
  # @param icon text
  def playground(text: "Toast", scheme: :default, icon: "checkbox-circle-fill")
    render component("ui/toast").new(text: text, scheme: scheme, icon: icon)
  end
end
