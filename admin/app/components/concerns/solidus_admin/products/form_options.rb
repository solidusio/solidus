# frozen_string_literal: true

module SolidusAdmin
  module Products
    module FormOptions
      private

      def option_type_options
        @option_type_options ||= Spree::OptionType.order(:presentation).pluck(:presentation, :name, :id).map do
          ["#{_2}:#{_1}", _3]
        end
      end
    end
  end
end
