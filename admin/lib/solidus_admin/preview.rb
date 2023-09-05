# frozen_string_literal: true

# This module will add all the necessary harness to a ViewComponent::Preview
# to be able to render Solidus components.
#
# Adds a `current_component` helper method that will return the the component class
# based on the preview class name. The component class name is inferred by removing
# the `Preview` suffix from the preview class name.
#
# Adds a `helpers` method that will return the helpers module from SolidusAdmin::BaseController
# making them available to the preview class (which is not a standard controller). All helpers
# are available to the preview class via `method_missing`.
#
# @example
#   class SolidusAdmin::UI::Badge::ComponentPreview < ViewComponent::Preview
#     include SolidusAdmin::Preview
#
#     def default
#       render current_component.new(name: time_ago_in_words(1.day.ago))
#     end
#   end
#
module SolidusAdmin::Preview
  extend ActiveSupport::Concern

  module ControllerHelper
    extend ActiveSupport::Concern

    included do
      include SolidusAdmin::ControllerHelpers::Auth
      helper ActionView::Helpers
      helper SolidusAdmin::ComponentsHelper
      helper_method :current_component
    end

    private

    def spree_current_user
      Spree::LegacyUser.new(email: "admin@example.com")
    end

    def authenticate_solidus_backend_user!
      # noop
    end

    def current_component
      @current_component ||= begin
        # Lookbook sets the @preview instance variable with a PreviewEntity instance, while ViewComponent uses the preview class.
        # Lookbook's PreviewEntity has `#preview_class_name` as part of its public api.
        # Since we want to support both ways or rendering components, we need to check.
        preview_class_name = @preview.respond_to?(:preview_class_name) ? @preview.preview_class_name : @preview.name
        preview_class_name.chomp("Preview").constantize
      end
    end
  end

  included do
    layout "solidus_admin/preview"

    delegate :helpers, to: SolidusAdmin::BaseController
    private :helpers # hide it from preview "example" methods
  end

  def current_component
    @current_component ||= self.class.name.chomp("Preview").constantize
  end

  private

  def method_missing(name, ...)
    if helpers.respond_to?(name)
      helpers.send(name, ...)
    else
      super
    end
  end

  def respond_to_missing?(name, include_private = false)
    helpers.respond_to?(name) || super
  end
end
