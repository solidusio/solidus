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

  def discover_title(page = current_page)
    markup = String(page.render( {layout: false} ))
    markup[/>(.*?)<\/h1>/, 1]
  end
end

class CodeBlockRender < Redcarpet::Render::HTML
  def block_code(code, language)
    path = code[/^#\s(\S*)\n/, 1]
    code = code.lines[1..-1].join if path
    template = File.read('source/partials/_code_block.erb')
    ERB.new(template).result(binding)
  end
end

set :markdown_engine, :redcarpet
set(
  :markdown,
  :fenced_code_blocks           => true,
  :tables                       => true,
  :renderer                     => CodeBlockRender
)

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
