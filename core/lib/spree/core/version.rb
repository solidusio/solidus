# frozen_string_literal: true

module Spree
  VERSION = "2.10.2"

  def self.solidus_version
    VERSION
  end

  def self.solidus_gem_version
    Gem::Version.new(solidus_version)
  end
end
