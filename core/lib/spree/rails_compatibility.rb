# frozen_string_literal: true

module Spree
  # Supported Rails versions compatibility
  #
  # This module is meant to wrap some Rails API changes between supported
  # versions. It's also meant to contain compatibility for features that we use
  # internally in the Solidus code base.
  module RailsCompatibility
    # Method `#to_fs`, since Rails 7
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
    def self.to_fs(value, *args, **kwargs, &block)
      if version_gte('7.0')
        value.to_fs(*args, **kwargs, &block)
      else
        value.to_s(*args, **kwargs, &block)
      end
    end

    def self.version_gte(version)
      ::Rails.gem_version >= Gem::Version.new(version)
    end
    private_class_method :version_gte
  end
end
