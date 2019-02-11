# frozen_string_literal: true

module NavHelpers
  def category_matches_page?(href)
    current_page.url.include?(href.sub(/\/[^\/]*$/, ''))
  end

  def current_guide
    current_subdirectory = current_page.path.sub(/\/.*$/, '')
    table_of_contents ? data.nav.global.public_send(current_subdirectory.to_sym) : config[:site_name]
  end

  def table_of_contents
    current_subdirectory = current_page.path.sub(/\/.*$/, '')
    data.nav.public_send(current_subdirectory.to_sym)
  end

  def discover_title(page = current_page)
    page_title = current_page.data.title || retrieve_page_header(page)
    category = page.path[/\/(.*?)\/.*\.html/, 1]
    guide_name = table_of_contents ? "Solidus #{current_guide.title}" : config[:site_name]

    return "#{guide_name}: #{page_title}" unless category

    category = category.tr('-', ' ').capitalize
    "#{category}: #{page_title} | #{guide_name}"
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
