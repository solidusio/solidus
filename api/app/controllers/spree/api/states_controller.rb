# frozen_string_literal: true

module Spree
  module Api
    class StatesController < Spree::Api::BaseController
      skip_before_action :authenticate_user

      def index
        @states = scope.ransack(params[:q]).result.
                    includes(:country).order('name ASC')

        if params[:page] || params[:per_page]
          @states = paginate(@states)
        end

        respond_with(@states)
      end

      def show
        @state = scope.find(params[:id])
        respond_with(@state)
      end

      private

      def scope
        if params[:country_id]
          @country = Spree::Country.accessible_by(current_ability, :read).find(params[:country_id])
          @country.states.accessible_by(current_ability, :read)
        else
          Spree::State.accessible_by(current_ability, :read)
        end
      end
    end
  end
end
