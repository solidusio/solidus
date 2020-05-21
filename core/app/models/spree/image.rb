# frozen_string_literal: true

module Spree
  class Image < Asset
    include ::Spree::Config.image_attachment_module

    # Backward compatibility patch while images are migrated to new habtm model
    scope :for_variants, -> (variant_ids) { where(viewable_type: 'Spree::Variant', viewable_id: variant_ids) }

    def mini_url
      Spree::Deprecation.warn(
        'Spree::Image#mini_url is DEPRECATED. Use Spree::Image#url(:mini) instead.'
      )
      url(:mini)
    end
  end
end
