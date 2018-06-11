# frozen_string_literal: true

module NavHelpers
  def category_matches_page?(href)
    current_page.url.include?(href.sub(/\/[^\/]*$/, ''))
  end

  def discover_title(page = current_page)
    page_title = current_page.data.title || retrieve_page_header(page)
    category = page.path[/\/(.*?)\/.*\.html/, 1]&.gsub('-', ' ')&.capitalize
    [category, page_title, "Solidus Developers Guide"].compact.join(" | ")
  end

  def kabob_case(title)
    title.tr(' ', '-').downcase
  end

  def menu_item_matches_page?(href)
    current_page.url.chomp('/').eql?(href)
  end

  def retrieve_page_header(page = current_page)
    markup = String(page.render( { layout: false } ))
    markup[/>(.*?)<\/h1>/, 1]
  end
end
