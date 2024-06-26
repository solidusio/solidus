# frozen_string_literal: true

module SolidusPromotions
  module Admin
    class BaseController < Spree::Admin::ResourceController
      def parent
        @parent ||= self.class.parent_data[:model_class]
          .includes(self.class.parent_data[:includes])
          .find_by!(self.class.parent_data[:find_by] => params["#{parent_model_name}_id"])
        instance_variable_set(:"@#{parent_model_name}", @parent)
      rescue ActiveRecord::RecordNotFound => e
        resource_not_found(flash_class: e.model.constantize, redirect_url: routes_proxy.polymorphic_url([:admin, parent_model_name.pluralize.to_sym]))
      end

      def new_object_url(options = {})
        if parent?
          routes_proxy.new_polymorphic_url([:admin, parent, model_class], options)
        else
          routes_proxy.new_polymorphic_url([:admin, model_class], options)
        end
      end

      def edit_object_url(object, options = {})
        if parent?
          routes_proxy.polymorphic_url([:edit, :admin, parent, object], options)
        else
          routes_proxy.polymorphic_url([:edit, :admin, object], options)
        end
      end

      def object_url(object = nil, options = {})
        target = object || @object

        if parent?
          routes_proxy.polymorphic_url([:admin, parent, target], options)
        else
          routes_proxy.polymorphic_url([:admin, target], options)
        end
      end

      def collection_url(options = {})
        if parent?
          routes_proxy.polymorphic_url([:admin, parent, model_class], options)
        else
          routes_proxy.polymorphic_url([:admin, model_class], options)
        end
      end

      def routes_proxy
        solidus_promotions
      end

      def parent_model_name
        self.class.parent_data[:model_name].gsub("solidus_promotions/", "")
      end
    end
  end
end
