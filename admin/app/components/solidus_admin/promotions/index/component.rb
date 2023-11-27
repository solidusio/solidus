# frozen_string_literal: true

class SolidusAdmin::Promotions::Index::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(page:)
    @page = page
  end

  def title
    Spree::Promotion.model_name.human.pluralize
  end

  def prev_page_path
    solidus_admin.url_for(**request.params, page: @page.number - 1, only_path: true) unless @page.first?
  end

  def next_page_path
    solidus_admin.url_for(**request.params, page: @page.next_param, only_path: true) unless @page.last?
  end

  def batch_actions
    [
      {
        display_name: t('.batch_actions.delete'),
        action: solidus_admin.promotions_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def filters
    [
      {
        presentation: Spree::PromotionCategory.model_name.human.pluralize,
        attribute: "promotion_category_id",
        predicate: "in",
        options: Spree::PromotionCategory.pluck(:name, :id)
      }
    ]
  end

  def scopes
    [
      { name: :active, label: t('.scopes.active'), default: true },
      { name: :draft, label: t('.scopes.draft') },
      { name: :future, label: t('.scopes.future') },
      { name: :expired, label: t('.scopes.expired') },
      { name: :all, label: t('.scopes.all') },
    ]
  end

  def columns
    [
      {
        header: :name,
        data: ->(promotion) do
          content_tag :div, promotion.name
        end
      },
      {
        header: :code,
        data: ->(promotion) do
          count = promotion.codes.count
          (count == 1) ? promotion.codes.pick(:value) : t('spree.number_of_codes', count: count)
        end
      },
      {
        header: :status,
        data: ->(promotion) do
          if promotion.active?
            render component('ui/badge').new(name: t('.status.active'), color: :green)
          else
            render component('ui/badge').new(name: t('.status.inactive'), color: :graphite_light)
          end
        end
      },
      {
        header: :usage_limit,
        data: ->(promotion) { promotion.usage_limit || icon_tag('infinity-line') }
      },
      {
        header: :uses,
        data: ->(promotion) { promotion.usage_count }
      },
      {
        header: :starts_at,
        data: ->(promotion) { promotion.starts_at ? l(promotion.starts_at, format: :long) : icon_tag('infinity-line') }
      },
      {
        header: :expires_at,
        data: ->(promotion) { promotion.expires_at ? l(promotion.expires_at, format: :long) : icon_tag('infinity-line') }
      },
    ]
  end
end
