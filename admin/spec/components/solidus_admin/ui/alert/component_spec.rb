# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::UI::Alert::Component, type: :component do
  it "renders the overview preview" do
    render_preview(:overview)
  end
end
