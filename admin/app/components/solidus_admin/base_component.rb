# frozen_string_literal: true

require "view_component/version"
require "view_component/translatable"

module SolidusAdmin
  # BaseComponent is the base class for all components in Solidus Admin.
  class BaseComponent < ViewComponent::Base
    include SolidusAdmin::ComponentsHelper
    include Turbo::FramesHelper

    def icon_tag(name, **attrs)
      render component("ui/icon").new(name: name, **attrs)
    end

    module InheritableTranslations
      def build_i18n_backend
        return if compiled?

        # We need to load the translations files from the ancestors so a component
        # can inherit translations from its parent and is able to overwrite them.
        translation_files = ancestors.reverse_each.with_object([]) do |ancestor, files|
          if ancestor.is_a?(Class) && ancestor < ViewComponent::Base
            files.concat(ancestor.sidecar_files(%w[yml yaml].freeze))
          end
        end

        # In development it will become nil if the translations file is removed
        self.i18n_backend = if translation_files.any?
          ViewComponent::Translatable::I18nBackend.new(
            i18n_scope: i18n_scope,
            load_paths: translation_files
          )
        end
      end
    end

    # Can be removed once https://github.com/ViewComponent/view_component/pull/1934 is released
    extend InheritableTranslations unless Gem::Version.new(ViewComponent::VERSION::STRING) >= Gem::Version.new("3.9")

    def missing_translation(key, options)
      keys = I18n.normalize_keys(options[:locale] || I18n.locale, key, options[:scope])

      logger.debug "  [#{self.class}] Missing translation: #{keys.join('.')}"

      if options[:locale] != :en
        t(key, **options, locale: :en)
      else
        "translation missing: #{keys.join('.')}"
      end
    end

    def self.stimulus_id
      @stimulus_id ||= name.underscore
        .sub(/^solidus_admin\/(.*)\/component$/, '\1')
        .gsub("/", "--")
        .tr("_", "-")
    end

    delegate :stimulus_id, to: :class

    def spree
      @spree ||= Spree::Core::Engine.routes.url_helpers
    end

    def solidus_admin
      @solidus_admin ||= SolidusAdmin::Engine.routes.url_helpers
    end
  end
end
