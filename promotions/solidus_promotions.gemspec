# frozen_string_literal: true

require_relative "../core/lib/spree/core/version"

Gem::Specification.new do |spec|
  spec.platform = Gem::Platform::RUBY
  spec.name = "solidus_promotions"
  spec.version = Spree.solidus_version
  spec.summary = "New promotion system for Solidus"
  spec.description = spec.summary

  spec.authors = ["Martin Meyerhoff", "Solidus Team"]
  spec.email = "contact@solidus.io"
  spec.homepage = "https://github.com/solidusio/solidus/blob/main/promotions/README.md"

  spec.license = "BSD-3-Clause"

  spec.metadata["homepage_uri"] = spec.homepage

  spec.required_ruby_version = ">= 3.2.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  files = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }
  spec.files = files.grep_v(%r{^(spec|bin)/})

  spec.add_dependency "csv", "~> 3.0"
  spec.add_dependency "importmap-rails", [">= 2.0", "< 3"]
  spec.add_dependency "ransack-enum", "~> 1.0"
  spec.add_dependency "solidus_core", [">= 4.0.0", "< 5"]
  spec.add_dependency "solidus_support", ">= 0.12.0"
  spec.add_dependency "stimulus-rails", "~> 1.2"
  spec.add_dependency "turbo-rails", ">= 1.4"
end
