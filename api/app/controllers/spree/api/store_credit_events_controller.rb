# frozen_string_literal: true

class Spree::Api::StoreCreditEventsController < Spree::Api::BaseController
  def mine
    if current_api_user
      @store_credit_events = paginate(
        current_api_user.store_credit_events.exposed_events
      ).reverse_chronological
    else
      render "spree/api/errors/unauthorized", status: :unauthorized
    end
  end
end
