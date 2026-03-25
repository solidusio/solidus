# frozen_string_literal: true

module Spree
  # Methods added to this helper will be available to all templates in the
  # frontend.
  module StoreHelper
    # @return [Boolean] true when it is appropriate to show the store menu
    def store_menu?
      %w[thank_you].exclude? params[:action]
    end
  end
end
