# frozen_string_literal: true

module Spree
  def self.solidus_version
    "2.8.0.alpha"
  end

  def self.solidus_gem_version
    Gem::Version.new(solidus_version)
  end
end
