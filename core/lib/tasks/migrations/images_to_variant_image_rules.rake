namespace 'spree:migrations:images_to_variant_image_rules' do
  # This migrates variant images to the new variant image rules.
  #
  # A variant image rule uses option values to determine which image to display,
  # therefor variant image rules do not support having different images for
  # variants that don't have different option values.
  #
  # If you have specific images associated with variants that do not have
  # assigned option values, make sure you associate option values to those
  # variants prior to running this migration task.
  task up: :environment do
    Spree::Image.where(viewable_type: "Spree::Variant").find_each do |variant_image|
      variant = variant_image.viewable
      product = variant.product

      image_rule = product.variant_image_rules.find do |image_rule|
        image_rule.applies_to_variant?(variant)
      end || product.variant_image_rules.build
      image_rule_image = image_rule.values.build(image: variant_image)
      image_rule.option_values = variant.option_values unless variant.is_master?
      image_rule.save!
      variant_image.update_attributes!(viewable: image_rule_image)
    end
  end

  task down: :environment do
    Spree::Image.where(viewable_type: "Spree::VariantImageRuleValue").find_each do |variant_image|
      variant_image_rule_value = variant_image.viewable
      image_rule = variant_image_rule_value.variant_image_rule
      product = image_rule.product
      product.variants_including_master.each do |variant|
        if image_rule.applies_to_variant?(variant)
          variant_image.update_attributes!(viewable: variant)
          break
        end
      end
    end
  end
end
