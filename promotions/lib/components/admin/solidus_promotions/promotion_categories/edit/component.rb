# frozen_string_literal: true

class SolidusPromotions::PromotionCategories::Edit::Component < SolidusAdmin::BaseComponent
  def initialize(record)
    super
    @promotion_category = record
  end

  def form_id
    dom_id(@promotion_category, "#{stimulus_id}_edit_promotion_category_form")
  end

  def form_url
    solidus_promotions.promotion_category_path(@promotion_category, **search_filter_params)
  end
end
