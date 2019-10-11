# frozen_string_literal: true

module Solidus
  module Api
    class CountriesController < Solidus::Api::BaseController
      skip_before_action :authenticate_user

      def index
        @countries = Solidus::Country.
          accessible_by(current_ability, :read).
          ransack(params[:q]).
          result.
          order('name ASC')

        country = Solidus::Country.order("updated_at ASC").last

        if stale?(country)
          @countries = paginate(@countries)
          respond_with(@countries)
        end
      end

      def show
        @country = Solidus::Country.accessible_by(current_ability, :read).find(params[:id])
        respond_with(@country)
      end
    end
  end
end
