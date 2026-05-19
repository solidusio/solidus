# frozen_string_literal: true

module Spree
  class Asset < Spree::Base
    belongs_to :viewable, polymorphic: true, touch: true, optional: true
    acts_as_list scope: [:viewable_id, :viewable_type]

    # Preload args to nest under asset-bearing associations, e.g.
    #   includes(variant_images: Spree::Image.attachment_preloads)
    #   includes(variants: { images: Spree::Image.attachment_preloads })
    #
    # Returns the ActiveStorage attachment + blob + variant preloads when the
    # asset class is in ActiveStorage mode, or an empty array (no-op nested
    # preload) when in Paperclip mode. Lets callers preload uniformly without
    # branching on the configured attachment backend.
    def self.attachment_preloads
      return [] unless reflect_on_association(:attachment_attachment)

      [{attachment_attachment: {blob: {variant_records: {image_attachment: :blob}}}}]
    end
  end
end
