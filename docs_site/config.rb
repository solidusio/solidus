page "/*.xml", layout: false
page "/*.json", layout: false
page "/*.txt", layout: false
page "/developers/*", layout: 'article'
page "/404.html", directory_index: false

set :css_dir, "assets/stylesheets"
set :images_dir, "assets/images"
set :js_dir, "assets/javascripts"
set :base_url, build? ? "https://solidus.io" : "http://localhost:4567"

helpers do
  def kabob_case(title)
    title.gsub(' ', '-').downcase
  end

  def category_matches_page?(href)
    current_page.url.include?(href.sub(/\/[^\/]*$/, ''))
  end

  def menu_item_matches_page?(href)
    current_page.url.chomp('/').eql?(href)
  end
end

activate :directory_indexes
#
activate :external_pipeline,
         name: :webpack,
         command: build? ?  "npm run production" : "npm run development",
         source: ".tmp",
         latency: 1

configure :build do
  # Append a hash to asset urls (make sure to use the url helpers)
  activate :asset_hash

  ignore "assets/javascripts/common.js"
  ignore "assets/stylesheets/site"
end

set(:port, 4568)
