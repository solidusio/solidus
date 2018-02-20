# frozen_string_literal: true

module Spree
  module Api
    class CountriesController < Spree::Api::BaseController
      skip_before_action :authenticate_user

      def index
        @countries = Spree::Country.
          accessible_by(current_ability, :read).
          ransack(params[:q]).
          result.
          order('name ASC')

        country = Spree::Country.order("updated_at ASC").last

        if stale?(country)
          @countries = paginate(@countries)
          respond_with(@countries)
        end
      end

      def show
        @country = Spree::Country.accessible_by(current_ability, :read).find(params[:id])
        respond_with(@country)
      end
    end
  end
end
