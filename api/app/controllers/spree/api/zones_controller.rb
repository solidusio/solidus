# frozen_string_literal: true

module Solidus
  module Api
    class ZonesController < Solidus::Api::BaseController
      def create
        authorize! :create, Zone
        @zone = Solidus::Zone.new(zone_params)
        if @zone.save
          respond_with(@zone, status: 201, default_template: :show)
        else
          invalid_resource!(@zone)
        end
      end

      def destroy
        authorize! :destroy, zone
        zone.destroy
        respond_with(zone, status: 204)
      end

      def index
        @zones = Solidus::Zone.
          accessible_by(current_ability, :read).
          order('name ASC').
          ransack(params[:q]).
          result

        @zones = paginate(@zones)

        respond_with(@zones)
      end

      def show
        respond_with(zone)
      end

      def update
        authorize! :update, zone
        if zone.update(zone_params)
          respond_with(zone, status: 200, default_template: :show)
        else
          invalid_resource!(zone)
        end
      end

      private

      def zone_params
        attrs = params.require(:zone).permit!
        if attrs[:zone_members]
          attrs[:zone_members_attributes] = attrs.delete(:zone_members)
        end
        attrs
      end

      def zone
        @zone ||= Solidus::Zone.accessible_by(current_ability, :read).find(params[:id])
      end
    end
  end
end
