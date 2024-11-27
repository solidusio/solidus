# frozen_string_literal: true

require "view_component/version"
require "view_component/translatable"

module SolidusAdmin
  # BaseComponent is the base class for all components in Solidus Admin.
  class BaseComponent < ViewComponent::Base
    include SolidusAdmin::ComponentsHelper
    include Turbo::FramesHelper

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

    class << self
      private

      def engines_with_routes
        Rails::Engine.subclasses.map(&:instance).reject do |engine|
          engine.routes.empty?
        end
      end
    end

    # For each engine with routes, define a method that returns the routes proxy.
    # This allows us to use the routes in the context of a component class.
    engines_with_routes.each do |engine|
      define_method(engine.engine_name) do
        engine.routes.url_helpers
      end
    end
  end
end
