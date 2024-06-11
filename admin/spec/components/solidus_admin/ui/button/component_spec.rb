# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::UI::Button::Component, type: :component do
  it "renders previews" do
    render_preview(:playground)
    render_preview(:overview)
    render_preview(:group)
  end
end
