# frozen_string_literal: true

module Solidus
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
