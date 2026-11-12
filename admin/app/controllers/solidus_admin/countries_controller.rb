# frozen_string_literal: true

module SolidusAdmin
  class CountriesController < SolidusAdmin::BaseController
    def states
      @states = Spree::State.where(country_id: params[:country_id])
      render json: @states.select(:id, :name)
    end

    private

    def authorize_solidus_admin_user! = authorize!(:admin, Spree::Country)
  end
end
