# frozen_string_literal: true

module Spree
  module Admin
    class ZonesController < ResourceController
      before_action :load_data, except: :index
      before_action :set_breadcrumbs

      def new
        @zone.zone_members.build
      end

      private

      def collection
        params[:q] ||= {}
        params[:q][:s] ||= "name asc"
        @search = super.ransack(params[:q])
        @zones = @search.result.page(params[:page]).per(params[:per_page])
      end

      def load_data
        @countries = Spree::Country.order(:name)
        @states = Spree::State.order(:name)
        @zones = Spree::Zone.order(:name)
      end

      def set_breadcrumbs
        add_breadcrumb t('spree.settings')
        add_breadcrumb plural_resource_name(Spree::Zone), spree.admin_zones_path
        add_breadcrumb @zone.name          if action_name == 'edit'
        add_breadcrumb t('spree.new_zone') if action_name == 'new'
      end
    end
  end
end
