module Solidus
  module Admin
    module ImagesHelper
      def options_text_for(image)
        if image.viewable.is_a?(Solidus::Variant)
          if image.viewable.is_master?
            Solidus.t(:all)
          else
            image.viewable.sku_and_options_text
          end
        else
          Solidus.t(:all)
        end
      end
    end
  end
end

