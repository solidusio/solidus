# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::UI::Forms::Field::Component, type: :component do
  before do
    create :product
    create_list :taxon, 3
  end

  it "renders the overview preview" do
    render_preview(:overview)
  end
end
