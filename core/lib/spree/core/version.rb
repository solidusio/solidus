# frozen_string_literal: true

module Spree
  VERSION = "3.4.4.dev"

  def self.solidus_version
    VERSION
  end

  def self.previous_solidus_minor_version
    '3.3'
  end

  def self.solidus_gem_version
    Gem::Version.new(solidus_version)
  end
end
