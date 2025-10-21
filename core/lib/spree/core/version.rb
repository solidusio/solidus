# frozen_string_literal: true

module Spree
  VERSION = "4.6.2.dev"

  def self.solidus_version = VERSION

  def self.minimum_required_rails_version = "7.0"

  def self.previous_solidus_minor_version = "4.5"

  def self.solidus_gem_version = Gem::Version.new(solidus_version)
end
