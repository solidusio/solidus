module Spree
  class Admin::TranslationsController < Admin::BaseController
    before_filter :load_parent

    helper_method :collection_url
    helper 'spree_i18n/locale'

    def index
      render resource_name
    end

    private
      def load_parent
        set_resource_ivar(resource)
      end

      def resource_name
        params[:resource].singularize
      end

      def set_resource_ivar(resource)
        instance_variable_set("@#{resource_name}", resource)
      end

      def klass
        @klass ||= "Spree::#{params[:resource].classify}".constantize
      end

      def resource
        @resource ||= if slugged_models.include? klass.class_name
          klass.friendly.find(params[:resource_id])
        else
          klass.find(params[:resource_id])
        end
      end

      def collection_url
        send "admin_#{resource_name}_url", @resource
      end

      def slugged_models
        ["SpreeProduct"]
      end
  end
end
