# frozen_string_literal: true

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
      if version_gte('7.0')
        value.to_fs(*args, **kwargs, &block)
      else
        value.to_s(*args, **kwargs, &block)
      end
    end

    # `raise_on_missing_translations` config option
    #
    # Changed from ActionView to I18n in Rails 6.1
    #
    # See https://github.com/rails/rails/pull/31571
    #
    # TODO: Remove when deprecating Rails 6.0
    def self.raise_on_missing_translations(value)
      if version_gte('6.1')
        Rails.application.config.i18n.raise_on_missing_translations = value
      else
        Rails.application.config.action_view.raise_on_missing_translations = value
      end
    end

    def self.version_gte(version)
      ::Rails.gem_version >= Gem::Version.new(version)
    end
    private_class_method :version_gte
  end
end
