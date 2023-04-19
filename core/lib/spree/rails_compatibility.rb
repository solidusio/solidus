# frozen_string_literal: true

require 'rails/gem_version'

module Spree
  # Supported Rails versions compatibility
  #
  # This module is meant to wrap some Rails API changes between supported
  # versions. It's also meant to contain compatibility for features that we use
  # internally in the Solidus code base.
  module RailsCompatibility
    # Default ActiveStorage variant processor
    #
    # Changed from `:mini_magick` to `vips` on Rails 7
    #
    # See https://github.com/rails/rails/issues/42744
    #
    # TODO: Remove when deprecating Rails 6.1
    def self.variant_processor
      version_gte?('7') ? :vips : :mini_magick
    end

    def self.version_gte?(version)
      ::Rails.gem_version >= Gem::Version.new(version)
    end
    private_class_method :version_gte?
  end
end
