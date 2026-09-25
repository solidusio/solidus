# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::UI::Forms::Select::Component, type: :component do
  before do
    country = create :country
    create :state, country:, state_code: "AL"
    create :state, country:, state_code: "AK"
    create :state, country:, state_code: "AZ"
  end

  it "renders the overview preview" do
    render_preview(:overview)
  end

  it "renders the playground preview" do
    render_preview(:playground)
  end
end
