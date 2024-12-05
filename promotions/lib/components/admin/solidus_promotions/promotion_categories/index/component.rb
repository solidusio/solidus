# frozen_string_literal: true

class SolidusPromotions::PromotionCategories::Index::Component < SolidusAdmin::UI::Pages::Index::Component
  def model_class
    SolidusPromotions::PromotionCategory
  end

  def row_url(promotion_category)
    edit_path(promotion_category)
  end

  def edit_path(promotion_category)
    solidus_promotions.edit_admin_promotion_category_path(promotion_category, **search_filter_params)
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t(".add"),
      href: solidus_promotions.new_admin_promotion_category_path,
      icon: "add-line"
    )
  end

  def batch_actions
    [
      {
        label: t(".batch_actions.delete"),
        action: solidus_promotions.promotion_categories_path,
        method: :delete,
        icon: "delete-bin-7-line"
      }
    ]
  end

  def columns
    [
      name_column,
      code_column
    ]
  end

  def name_column
    {
      header: :name,
      data: ->(promotion_category) do
        link_to promotion_category.name, edit_path(promotion_category), class: "body-link"
      end
    }
  end

  def code_column
    {
      header: :code,
      data: ->(promotion_category) do
        link_to promotion_category.code, edit_path(promotion_category), class: "body-link"
      end
    }
  end

  def solidus_promotions
    @solidus_promotions ||= SolidusPromotions::Engine.routes.url_helpers
  end
end
