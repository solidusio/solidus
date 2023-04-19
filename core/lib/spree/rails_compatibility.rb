# frozen_string_literal: true

require 'rails/gem_version'

module Spree
  # Supported Rails versions compatibility
  #
  # This module is meant to wrap some Rails API changes between supported
  # versions. It's also meant to contain compatibility for features that we use
  # internally in the Solidus code base.
  module RailsCompatibility
    # Method `#to_fs`
    #
    # Available since Rails 7.0, substitutes `#to_s(format)`
    #
    # It includes:
    #
    # ActiveSupport::NumericWithFormat
    # ActiveSupport::RangeWithFormat
    # ActiveSupport::TimeWithZone
    # Array
    # Date
    # DateTime
    # Time
    #
    # See https://github.com/rails/rails/pull/43772 &
    # https://github.com/rails/rails/pull/44354
    #
    # TODO: Remove when deprecating Rails 6.1
    def self.to_fs(value, *args, **kwargs, &block)
      if version_gte?('7.0')
        value.to_fs(*args, **kwargs, &block)
      else
        value.to_s(*args, **kwargs, &block)
      end
    end

    # Set default image at for Rails 6.0 dynamic default attachment module)
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
