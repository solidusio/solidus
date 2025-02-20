# frozen_string_literal: true

module Spree
  VERSION = "4.5.1.dev"

  def self.solidus_version
    VERSION
  end

  def self.previous_solidus_minor_version
    '4.4'
  end

  def self.solidus_gem_version
    Gem::Version.new(solidus_version)
  end
end
