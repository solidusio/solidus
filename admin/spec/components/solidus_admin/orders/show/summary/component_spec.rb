# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Orders::Show::Summary::Component, type: :component do
  it "renders the overview preview" do
    render_preview(:overview)
  end
end
