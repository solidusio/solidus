# frozen_string_literal: true

require "solidus_admin/main_nav_item"

class SolidusAdmin::Typography::TypographyPreview < ViewComponent::Preview
  layout "solidus_admin/preview"

  # Typography showcase
  #
  # Showcase of the custom Tailwind classes available for typography. It doesn't
  # correspond to a specific component.
  def overview
    render_with_template
  end
end
