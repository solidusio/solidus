# frozen_string_literal: true

module Spree
  VERSION = "4.3.0.dev"

  def self.solidus_version
    VERSION
  end

  def self.previous_solidus_minor_version
    '4.2'
  end

  def self.solidus_gem_version
    Gem::Version.new(solidus_version)
  end
end
