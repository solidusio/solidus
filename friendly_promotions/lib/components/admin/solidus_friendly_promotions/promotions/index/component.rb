# frozen_string_literal: true

class SolidusFriendlyPromotions::Promotions::Index::Component < SolidusAdmin::UI::Pages::Index::Component
  def model_class
    SolidusFriendlyPromotions::Promotion
  end

  def search_key
    :name_or_codes_value_or_path_or_description_cont
  end

  def search_url
    solidus_friendly_promotions.promotions_path
  end

  def row_url(promotion)
    solidus_friendly_promotions.admin_promotion_path(promotion)
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t(".add"),
      href: solidus_friendly_promotions.new_admin_promotion_path,
      icon: "add-line"
    )
  end

  def batch_actions
    [
      {
        label: t(".batch_actions.delete"),
        action: solidus_friendly_promotions.promotions_path,
        method: :delete,
        icon: "delete-bin-7-line"
      }
    ]
  end

  def scopes
    [
      {name: :active, label: t(".scopes.active"), default: true},
      {name: :draft, label: t(".scopes.draft")},
      {name: :future, label: t(".scopes.future")},
      {name: :expired, label: t(".scopes.expired")},
      {name: :all, label: t(".scopes.all")}
    ]
  end

  def filters
    [
      {
        label: SolidusFriendlyPromotions::PromotionCategory.model_name.human.pluralize,
        attribute: "promotion_category_id",
        predicate: "in",
        options: SolidusFriendlyPromotions::PromotionCategory.pluck(:name, :id)
      }
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
          (count == 1) ? promotion.codes.pick(:value) : t("spree.number_of_codes", count: count)
        end
      },
      {
        header: :status,
        data: ->(promotion) do
          if promotion.active?
            render component("ui/badge").new(name: t(".status.active"), color: :green)
          else
            render component("ui/badge").new(name: t(".status.inactive"), color: :graphite_light)
          end
        end
      },
      {
        header: :usage_limit,
        data: ->(promotion) { promotion.usage_limit || icon_tag("infinity-line") }
      },
      {
        header: :uses,
        data: ->(promotion) { promotion.usage_count }
      },
      {
        header: :starts_at,
        data: ->(promotion) { promotion.starts_at ? l(promotion.starts_at, format: :long) : icon_tag("infinity-line") }
      },
      {
        header: :expires_at,
        data: ->(promotion) { promotion.expires_at ? l(promotion.expires_at, format: :long) : icon_tag("infinity-line") }
      }
    ]
  end

  def solidus_friendly_promotions
    @solidus_friendly_promotions ||= SolidusFriendlyPromotions::Engine.routes.url_helpers
  end
end
