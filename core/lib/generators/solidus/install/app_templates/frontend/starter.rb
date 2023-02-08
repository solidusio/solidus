apply "#{__dir__}/break_down_solidus_gem.rb"
run_bundle

branch = "main"
current_timestamp = Time.now.strftime("%F %H:%M:%S")
uncachable_reference = "#{branch}@{#{current_timestamp}}"

apply URI.encode("https://github.com/solidusio/solidus_starter_frontend/raw/#{uncachable_reference}/template.rb")
