# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::UI::Forms::TextArea::Component, type: :component do
  it "renders the overview preview" do
    render_preview(:overview)
  end

  it "renders the playground preview" do
    render_preview(:playground)
  end
end
