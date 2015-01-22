module Spree
  module Stock
    class AvailabilityValidator < ActiveModel::Validator
      def validate(line_item)
        quantifier = Stock::Quantifier.new(line_item.variant)

        unless quantifier.can_supply? line_item.quantity
          variant = line_item.variant
          display_name = %Q{#{variant.name}}
          display_name += %Q{ (#{variant.options_text})} unless variant.options_text.blank?

          line_item.errors[:quantity] << Spree.t(
            :selected_quantity_not_available,
            item: display_name.inspect
          )
        end
      end
    end
  end
end
