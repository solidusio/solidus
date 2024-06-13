# frozen_string_literal: true

class SolidusAdmin::Orders::Show::Adjustments::Index::Adjustment::SpreePromotionAction::Component < SolidusAdmin::Orders::Show::Adjustments::Index::Adjustment::Component
  def detail
    link_to("#{model_name}: #{promotion_name}", spree.edit_admin_promotion_path(adjustment.source_id), class: "body-link")
  end

  private

  def promotion_name
    source.promotion.name
  end
end
