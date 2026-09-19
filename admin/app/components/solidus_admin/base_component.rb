# frozen_string_literal: true

require "view_component/version"
require "view_component/translatable"

module SolidusAdmin
  # BaseComponent is the base class for all components in Solidus Admin.
  class BaseComponent < ViewComponent::Base
    include SolidusAdmin::ComponentsHelper
    include SolidusAdmin::StimulusHelper
    include SolidusAdmin::VoidElementsHelper
    include SolidusAdmin::SolidusFormHelper
    include Turbo::FramesHelper

    def icon_tag(name, **attrs)
      render component("ui/icon").new(name:, **attrs)
    end

    # Log missing translations instead of rendering ActionView's
    # `translation_missing` span, falling back to the English translation.
    def translate(key = nil, **options)
      super(key, **options, raise: true)
    rescue ::I18n::MissingTranslationData
      missing_translation(self.class.__vc_i18n_key(key, options[:scope]), options.except(:scope))
    end
    alias_method :t, :translate

    def missing_translation(key, options)
      keys = I18n.normalize_keys(options[:locale] || I18n.locale, key, options[:scope])

      logger.debug "  [#{self.class}] Missing translation: #{keys.join(".")}"

      if (options[:locale] || I18n.default_locale) != :en
        t(key, **options, locale: :en)
      else
        "translation missing: #{keys.join(".")}"
      end
    end

    # ViewComponent assigns `virtual_path` in its `inherited` hook, which runs
    # before an anonymous subclass has been given a name. Resolve it lazily so
    # that translation scopes also work for dynamically built components.
    def self.virtual_path
      @virtual_path ||= name&.underscore
    end

    def self.stimulus_id
      @stimulus_id ||= name.underscore
        .sub(/^solidus_admin\/(.*)\/component$/, '\1')
        .gsub("/", "--")
        .tr("_", "-")
    end

    delegate :stimulus_id, to: :class
    delegate :search_filter_params, to: :helpers
  end
end
