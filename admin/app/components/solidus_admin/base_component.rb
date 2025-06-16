# frozen_string_literal: true

require "view_component/version"
require "view_component/translatable"

module SolidusAdmin
  # BaseComponent is the base class for all components in Solidus Admin.
  class BaseComponent < ViewComponent::Base
    include SolidusAdmin::ComponentsHelper
    include SolidusAdmin::StimulusHelper
    include SolidusAdmin::VoidElementsHelper
    include SolidusAdmin::FlashHelper
    include ::Turbo::FramesHelper
    include ::Turbo::StreamsHelper

    def icon_tag(name, **attrs)
      render component("ui/icon").new(name:, **attrs)
    end

    def missing_translation(key, options)
      keys = I18n.normalize_keys(options[:locale] || I18n.locale, key, options[:scope])

      logger.debug "  [#{self.class}] Missing translation: #{keys.join('.')}"

      if (options[:locale] || I18n.default_locale) != :en
        t(key, **options, locale: :en)
      else
        "translation missing: #{keys.join('.')}"
      end
    end

    def self.i18n_scope
      @i18n_scope ||= name.underscore.tr("/", ".")
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
