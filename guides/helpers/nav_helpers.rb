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
    category = page.path[/\/(.*?)\/.*\.html/, 1]&.gsub('-', ' ')&.capitalize
    page_title = current_page.data.title || retrieve_page_header(page)
    table_of_contents ? guide = "Solidus #{current_guide.title}" : guide = config[:site_name]
    "#{category}: #{page_title} | #{guide}"
  end

  def kabob_case(title)
    title.gsub(' ', '-').downcase
  end

  def menu_item_matches_page?(href)
    current_page.url.chomp('/').eql?(href)
  end

  def retrieve_page_header(page = current_page)
    markup = String(page.render( {layout: false} ))
    markup[/>(.*?)<\/h1>/, 1]
  end
end
