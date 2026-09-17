# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::UI::Modal::Component, type: :component do
  it "renders the overview preview" do
    render_preview(:with_text)
    render_preview(:with_form)
  end
end
