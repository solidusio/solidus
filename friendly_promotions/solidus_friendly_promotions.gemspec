# frozen_string_literal: true

require_relative "lib/solidus_friendly_promotions/version"

Gem::Specification.new do |spec|
  spec.name = "solidus_friendly_promotions"
  spec.version = SolidusFriendlyPromotions::VERSION
  spec.authors = ["Martin Meyerhoff"]
  spec.email = "mamhoff@gmail.com"

  spec.summary = "A replacement for Solidus' promotion system"
  spec.description = "Experimental replacement for the promotion system in Solidus"
  spec.homepage = "https://github.com/solidusio-contrib/solidus_friendly_promotions#readme"
  spec.license = "BSD-3-Clause"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/solidusio-contrib/solidus_friendly_promotions"
  spec.metadata["changelog_uri"] = "https://github.com/solidusio-contrib/solidus_friendly_promotions/blob/master/CHANGELOG.md"

  spec.required_ruby_version = Gem::Requirement.new(">= 2.5", "< 4")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  files = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }

  spec.files = files.grep_v(%r{^(test|spec|features)/})
  spec.bindir = "exe"
  spec.executables = files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "solidus_core", [">= 4.0.0", "< 5"]
  spec.add_dependency "solidus_support", "~> 0.5"
  spec.add_dependency "turbo-rails", "~> 1.4"

  spec.add_development_dependency "importmap-rails", "~> 1.2"
  spec.add_development_dependency "rspec-activemodel-mocks", "~> 1.0"
  spec.add_development_dependency "shoulda-matchers", "~> 5.3"
  spec.add_development_dependency "solidus_dev_support", "~> 2.6"
end
