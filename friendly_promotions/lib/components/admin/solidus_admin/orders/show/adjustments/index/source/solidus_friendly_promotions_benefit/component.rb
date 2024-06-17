# frozen_string_literal: true

class SolidusAdmin::Orders::Show::Adjustments::Index::Source::SolidusFriendlyPromotionsBenefit::Component < SolidusAdmin::Orders::Show::Adjustments::Index::Source::Component
  def detail
    link_to("#{model_name}: #{promotion_name}", solidus_friendly_promotions.edit_admin_promotion_path(adjustment.source_id), class: "body-link")
  end

  private

  def promotion_name
    source.promotion.name
  end

  def solidus_friendly_promotions
    @solidus_friendly_promotions ||= SolidusFriendlyPromotions::Engine.routes.url_helpers
  end
end
