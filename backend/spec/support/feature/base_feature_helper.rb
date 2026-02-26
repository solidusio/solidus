# frozen_string_literal: true

module BaseFeatureHelper
  def within_nav(&block)
    if Spree::Backend::Config.admin_updated_navbar
      within(".solidus-admin--nav", &block)
    else
      within(".admin-nav", &block)
    end
  end

  def click_nav(nav_text, subnav_text = nil)
    primary_nav = if Spree::Backend::Config.admin_updated_navbar
      find("ul.solidus-admin--nav--menu>li>a", text: /#{nav_text}/i)
    else
      find(".admin-nav-menu>ul>li>a", text: /#{nav_text}/i)
    end

    if subnav_text
      if Capybara.current_driver == :rack_test
        # RackTest implementation of `hover`raises NotImplementedError
        # noop
      else
        # Make the navigation visible with Selenium driver,
        if Spree::Backend::Config.admin_updated_navbar # rubocop:disable Style/IfInsideElse
          primary_nav.click
        else
          primary_nav.hover
        end
      end

      primary_nav.sibling("ul").find("li > a", text: /#{subnav_text}/i).click
    else
      primary_nav.click
    end
  end
end
