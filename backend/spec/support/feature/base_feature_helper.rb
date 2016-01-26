module BaseFeatureHelper
  def click_nav(nav_text, subnav_text = nil)
    primary_nav = find(".admin-nav-menu>ul>li>a", text: /#{nav_text}/i)
    if subnav_text
      primary_nav.find('+ul>li>a', text: /#{subnav_text}/i).click
    else
      primary_nav.click
    end
  end
end
