# frozen_string_literal: true

module Spree
  class ContentController < Spree::StoreController
    respond_to :html

    def cvv
      render layout: false
    end
  end
end
