solidus = Bundler.locked_gems.dependencies['solidus']

# `solidus_frontend` is not sourced from rubygems if the solidus gem was not.
github_solidus_frontend = '--github solidusio/solidus_frontend' unless solidus.nil? || solidus.source.is_a?(Bundler::Source::Rubygems)

bundle_command("add solidus_frontend #{github_solidus_frontend}")
generate 'solidus_frontend:install'
