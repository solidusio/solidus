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

    # `raise_on_missing_translations` config option
    #
    # Changed from ActionView to I18n on Rails 6.1
    #
    # See https://github.com/rails/rails/pull/31571
    #
    # TODO: Remove when deprecating Rails 6.0
    def self.raise_on_missing_translations(value)
      if version_gte?('6.1')
        Rails.application.config.i18n.raise_on_missing_translations = value
      else
        Rails.application.config.action_view.raise_on_missing_translations = value
      end
    end

    # Set default image attachment adapter
    #
    # TODO: Remove when deprecating Rails 6.0
    def self.default_image_attachment_module
      if version_gte?("6.1")
        "Spree::Image::ActiveStorageAttachment"
      else
        "Spree::Image::PaperclipAttachment"
      end
    end

    # Set default taxon attachment adapter
    #
    # TODO: Remove when deprecating Rails 6.0
    def self.default_taxon_attachment_module
      if version_gte?("6.1")
        "Spree::Taxon::ActiveStorageAttachment"
      else
        "Spree::Taxon::PaperclipAttachment"
      end
    end

    # Set current host for ActiveStorage in a controller
    #
    # Changed from `#host` to including a module in Rails 6
    #
    # See https://github.com/rails/rails/commit/e33c3cd8ccbecaca6c6af0438956431b02cb3fb2
    #
    # TODO: Remove when deprecating Rails 5.2
    def self.active_storage_set_current(controller)
      if version_gte?('6')
        controller.include ActiveStorage::SetCurrent
      else
        controller.before_action do
          ActiveStorage::Current.host = request.base_url
        end
      end
    end

    # Set current host for ActiveStorage
    #
    # Changed from `#host` to `#url_options` on Rails 7
    #
    # See https://github.com/rails/rails/issues/41388
    #
    # TODO: Remove when deprecating Rails 6.1
    def self.active_storage_url_options_host(value)
      if version_gte?('7')
        ActiveStorage::Current.url_options = { host: value }
      else
        ActiveStorage::Current.host = value
      end
    end

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
