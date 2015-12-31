module Spree
  module Admin
    class VariantsIncludingMasterController < VariantsController

      def model_class
        Solidus::Variant
      end

      def object_name
        "variant"
      end

    end
  end
end
