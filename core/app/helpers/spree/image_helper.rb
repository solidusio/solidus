module Spree
  module ImageHelper
    # Returns a string with a single id or comma separated ids
    # based on the image's viewable type.
    #
    # @param image [Spree::Image] the image
    # @return String string containing an id or comma separated ids
    def image_dom_id(image)
      case image.viewable
      when Spree::Product, Spree::Variant
        image.viewable.id.to_s
      when Spree::VariantImageRuleValue
        image_rule = image.viewable.variant_image_rule
        variants = image_rule.product.variants.select do |variant|
          image_rule.applies_to_variant?(variant)
        end
        variants.map(&:id).join(',')
      else
        raise "Unexpected viewable type"
      end
    end
  end
end
