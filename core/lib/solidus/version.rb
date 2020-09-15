# frozen_string_literal: true

module Solidus
  VERSION = "2.11.0.alpha"

  def self.gem_version
    Gem::Version.new(VERSION)
  end
end

# Legacy support

module Spree
  VERSION = Solidus::VERSION

  def self.solidus_version
    Solidus::VERSION
  end

  def self.solidus_gem_version
    Solidus.gem_version
  end
end
