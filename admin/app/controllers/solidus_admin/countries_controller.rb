# frozen_string_literal: true

module SolidusAdmin
  class CountriesController < SolidusAdmin::BaseController
    skip_before_action :authorize_solidus_admin_user!

    def states
      @states = Spree::State.where(country_id: params[:country_id])
      render json: @states.select(:id, :name)
    end
  end
end
