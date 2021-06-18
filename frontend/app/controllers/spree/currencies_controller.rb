# frozen_string_literal: true

module Spree
  class CurrenciesController < Spree::StoreController
    def set
      switch_currency(params[:switch_to_currency])
      current_order&.empty!

      redirect_back(fallback_location: root_path)
    end
  end
end
