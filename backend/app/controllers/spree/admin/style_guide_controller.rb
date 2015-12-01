module Spree
  module Admin
    class StyleGuideController < Spree::Admin::BaseController
      respond_to :html
      layout '/spree/layouts/admin_style_guide'

      def index
        @topics = {
          typography: [
            'fonts',
            'colors',
            'tags'
          ]
        }
      end
    end
  end
end
