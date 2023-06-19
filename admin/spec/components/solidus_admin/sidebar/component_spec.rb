# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Sidebar::Component, type: :component do
  it "renders the logo component" do
    logo_component = mock_component { erb_template "Logo" }

    render_inline(described_class.new(solidus_logo_component: logo_component))

    expect(page).to have_content("Logo")
  end

  it "renders the main navigation component" do
    main_nav_component = mock_component { erb_template "Main navigation" }

    render_inline(described_class.new(main_nav_component: main_nav_component))

    expect(page).to have_content("Main navigation")
  end
end
