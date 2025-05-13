# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::UI::Forms::Address::Component, type: :component do
  it "renders the overview preview" do
    render_preview(:overview)
  end

  it "renders with_extended_fields preview" do
    render_preview(:with_extended_fields)
  end

  it "renders with_custom_fieldset preview" do
    render_preview(:with_custom_fieldset)
  end
end
