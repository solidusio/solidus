# frozen_string_literal: true

require 'helpers/nav_helpers'
require 'helpers/image_helpers'
require 'lib/custom_markdown_renderer'

page "/*.xml", layout: false
page "/*.json", layout: false
page "/*.txt", layout: false
page "/developers/*", layout: 'article'
page "/contributing*", layout: 'article'
page "/acknowledgements*", layout: 'article'
page "/404.html", directory_index: false

# Temporarily redirect /index.html to /developers/index.html
redirect 'index.html', to: '/developers/index.html'

set :site_name, "Solidus Guides"
set :css_dir, "assets/stylesheets"
set :images_dir, "assets/images"
set :js_dir, "assets/javascripts"
set :base_url, build? ? "https://solidus.io" : "http://localhost:4567"

activate :directory_indexes
page "/developers/*", directory_index: false
page "/contributing*", directory_index: false
page "/acknowledgements*", directory_index: false
page "/users/*", directory_index: false

set :markdown_engine, :redcarpet

set :markdown,
  tables: true,
  autolink: true,
  fenced_code_blocks: true,
  footnotes: true,
  smartypants: true,
  with_toc_data: true,
  renderer: CustomMarkdownRenderer

activate :external_pipeline,
         name: :webpack,
         command: build? ? "npm run production" : "npm run development",
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
