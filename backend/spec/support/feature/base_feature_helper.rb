# frozen_string_literal: true

module BaseFeatureHelper
  def click_nav(nav_text, subnav_text = nil)
    primary_nav = find(".admin-nav-menu>ul>li>a", text: /#{nav_text}/i)
    if subnav_text
      unless Capybara.current_driver == :rack_test
        # we need to make the navigation visible with Selenium driver,
        # and RackTest implementation of `hover`raises NotImplementedError
        primary_nav.hover
      end
      primary_nav.sibling("ul").find("li > a", text: /#{subnav_text}/i).click
    else
      primary_nav.click
    end
  end
end
