module Spree
  class ContentController < Solidus::StoreController
    respond_to :html

    def cvv
      render :layout => false
    end
  end
end
