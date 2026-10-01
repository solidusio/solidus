# frozen_string_literal: true

module SolidusAdmin
  module Products
    module FormOptions
      private

      def taxon_options
        @taxon_options ||= Spree::Taxon.order(:lft).pluck(:name, :id, :lft, :depth).map do
          name, id, _lft, depth = _1
          ["#{"    " * depth} → #{name}", id, {data: {item_label: name}}]
        end
      end

      def option_type_options
        @option_type_options ||= Spree::OptionType.order(:presentation).pluck(:presentation, :name, :id).map do
          ["#{_2}:#{_1}", _3]
        end
      end
    end
  end
end
