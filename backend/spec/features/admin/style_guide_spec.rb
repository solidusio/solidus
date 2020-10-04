# frozen_string_literal: true

require 'spec_helper'

describe "Style guide", type: :feature do
  stub_authorization!

  it "should render successfully" do
    visit "/admin/style_guide"

    # Somewhere in a style guide you'd expect to talk about colors
    expect(page).to have_text "Colors"
  end
end
