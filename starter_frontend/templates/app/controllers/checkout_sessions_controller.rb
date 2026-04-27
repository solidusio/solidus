# frozen_string_literal: true

class CheckoutSessionsController < CheckoutBaseController
  def new
    @user = Spree::User.new
  end
end
