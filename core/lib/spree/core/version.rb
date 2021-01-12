# frozen_string_literal: true

module Spree
  VERSION = "2.11.4"

  def self.solidus_version
    VERSION
  end

  def self.solidus_gem_version
    Gem::Version.new(solidus_version)
  end
end
