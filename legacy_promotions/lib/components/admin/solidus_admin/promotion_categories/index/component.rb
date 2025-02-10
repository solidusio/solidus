# frozen_string_literal: true

class SolidusAdmin::PromotionCategories::Index::Component < SolidusAdmin::UI::Pages::Index::Component
  def model_class
    Spree::PromotionCategory
  end

  def title
    t('solidus_admin.promotion_categories.title')
  end

  def edit_path(record)
    solidus_admin.edit_promotion_category_path(record, **search_filter_params)
  end

  def turbo_frames
    %w[resource_modal]
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: solidus_admin.new_promotion_category_path(**search_filter_params),
      data: { turbo_frame: :resource_modal },
      icon: "add-line",
    )
  end

  def batch_actions
    [
      {
        label: t('.batch_actions.delete'),
        action: solidus_admin.promotion_categories_path(**search_filter_params),
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
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
      data: ->(record) do
        link_to record.name, edit_path(record),
          data: { turbo_frame: :resource_modal },
          class: 'body-link'
      end
    }
  end

  def code_column
    {
      header: :code,
      data: ->(record) do
        link_to record.code, edit_path(record),
          data: { turbo_frame: :resource_modal },
          class: 'body-link'
      end
    }
  end
end
