# frozen_string_literal: true

class SolidusAdmin::PromotionCategories::Index::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(promotion_categories:)
    @promotion_categories = promotion_categories
  end

  def title
    Spree::PromotionCategory.model_name.human.pluralize
  end

  def columns
    [
      name_column,
      code_column,
    ]
  end

  def name_column
    {
      header: :name,
      data: ->(promotion_category) do
        content_tag :div, promotion_category.name
      end
    }
  end

  def code_column
    {
      header: :code,
      data: ->(promotion_category) do
        content_tag :div, promotion_category.code
      end
    }
  end

  def batch_actions
    [
      {
        display_name: t('.batch_actions.delete'),
        action: solidus_admin.promotion_categories_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end
end
