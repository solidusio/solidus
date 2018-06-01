# frozen_string_literal: true

require 'helpers/image_helpers'

page "/*.xml", layout: false
page "/*.json", layout: false
page "/*.txt", layout: false
page "/developers/*", layout: 'article'
page "/contributing*", layout: 'article'
page "/acknowledgements*", layout: 'article'
page "/404.html", directory_index: false

set :css_dir, "assets/stylesheets"
set :images_dir, "assets/images"
set :js_dir, "assets/javascripts"
set :base_url, build? ? "https://solidus.io" : "http://localhost:4567"

activate :directory_indexes
page "/developers/*", :directory_index => false
page "/contributing*", :directory_index => false
page "/acknowledgements*", :directory_index => false

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

  def retrieve_page_header(page = current_page)
    markup = String(page.render( {layout: false} ))
    markup[/>(.*?)<\/h1>/, 1]
  end

  def discover_title(page = current_page)
    page_title = current_page.data.title || retrieve_page_header(page)
    category = page.path[/\/(.*?)\/.*\.html/, 1]&.gsub('-', ' ')&.capitalize
    [category, page_title, "Solidus Developers Guide"].compact.join(" | ")
  end
end

class CustomMarkdownRenderer < Redcarpet::Render::HTML
  include ImageHelpers

  def block_code(code, language)
    path = code.lines.first[/^#\s(\S*)$/, 1]
    code = code.lines[1..-1].join if path
    code = code.gsub('<', '&lt').gsub('>', '&gt')
    template = File.read('source/partials/_code_block.erb')
    ERB.new(template).result(binding)
  end

  def table(header, body)
    header_labels = header.scan(/<th>([\s\S]*?)<\/th>/).flatten
    table_rows = parse_table(body)
    template = File.read('source/partials/_table.erb')
    ERB.new(template).result(binding)
  end

  def header(text, header_level)
    "<h%s id=\"%s\" class=\"offset\">%s</h%s>" % [header_level, text.parameterize, text, header_level]
  end

  def link(link, title, content)
    template = File.read('source/partials/_anchor.erb')
    ERB.new(template).result(binding)
  end

  private

  # This function takes an HTML string and parses it into a nested list
  # The outer list represents table rows, while the inner lists represent the table data itself
  def parse_table(table_body)
    [].tap do |table_rows|
      table_body.scan(/<tr>([\s\S]*?)<\/tr>/).flatten.each do |tr_inner_markup|
        tds = []
        tr_inner_markup.scan(/<td>([\s\S]*?)<\/td>/).flatten.each do |td_inner_markup|
          tds << td_inner_markup
        end
        table_rows << tds
      end
    end
  end
end

set :markdown_engine, :redcarpet

set :markdown,
  :tables => true,
  :autolink => true,
  :fenced_code_blocks => true,
  :footnotes => true,
  :smartypants => true,
  :with_toc_data => true,
  :renderer => CustomMarkdownRenderer

activate :external_pipeline,
         name: :webpack,
         command: build? ?  "npm run production" : "npm run development",
         source: ".tmp",
         latency: 1

activate :s3_sync do |s3_sync|
  s3_sync.bucket = ENV["AWS_BUCKET"]
  s3_sync.region = ENV["AWS_REGION"]
  s3_sync.aws_access_key_id = ENV["AWS_ACCESS"]
  s3_sync.aws_secret_access_key = ENV["AWS_SECRET"]
end

default_caching_policy max_age: (60 * 60 * 24 * 365)
caching_policy "text/html", max_age: 0, must_revalidate: true
caching_policy "application/xml", max_age: 0, must_revalidate: true

configure :build do
  activate :asset_hash
end
