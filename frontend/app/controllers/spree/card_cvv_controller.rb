# frozen_string_literal: true

module Spree
  class CardCvvController < Spree::StoreController
    respond_to :html

    def index
      render layout: false
    end
  end
end
