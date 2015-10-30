module Spree
  class VariantImageRuleValue < Spree::Base
    acts_as_list
    belongs_to :variant_image_rule, touch: true
    belongs_to :image, dependent: :destroy, class_name: 'Spree::Image'

    validates :image, presence: true

    after_destroy :destroy_rule_without_values

    default_scope -> { order(:position) }

    def image_attachment
      image.attachment if image
    end

    def image_attachment=(attachment)
      if image
        image.attachment = attachment
      else
        self.build_image(viewable: self, attachment: attachment)
      end
    end

    def image_alt
      image.alt if image
    end

    def image_alt=(alt)
      if image
        image.alt = alt
      else
        self.build_image(viewable: self, alt: alt)
      end
    end

    private
      # A variant image rule should always contain
      # at least one value. This ensures that when
      # a rule's last value is destroyed, the parent
      # rule is also destroyed.
      def destroy_rule_without_values
        if variant_image_rule.values.empty?
          variant_image_rule.destroy
        end
      end
  end
end
