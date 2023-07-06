# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::UI::Table::Component, type: :component do
  it "renders a simple table" do
    render_preview(:simple)
  end
end
