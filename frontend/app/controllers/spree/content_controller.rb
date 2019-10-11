# frozen_string_literal: true

module Solidus
  class ContentController < Solidus::StoreController
    respond_to :html

    def cvv
      render layout: false
    end
  end
end
