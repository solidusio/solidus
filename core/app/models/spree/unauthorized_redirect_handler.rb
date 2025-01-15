# frozen_string_literal: true

module Spree
  # This service object is responsible for handling unauthorized redirects
  class UnauthorizedRedirectHandler
    # @param controller [ApplicationController] an instance of ApplicationController
    #  or its subclasses.
    def initialize(controller)
      @controller = controller
    end

    # This method is responsible for handling unauthorized redirects
    def call
      flash[:error] = I18n.t('spree.authorization_failure')
      redirect_back(fallback_location: "/unauthorized")
    end

    private

    attr_reader :controller

    delegate :flash, :redirect_back, to: :controller
  end
end
