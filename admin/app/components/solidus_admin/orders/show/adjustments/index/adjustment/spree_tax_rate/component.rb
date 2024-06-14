# frozen_string_literal: true

class SolidusAdmin::Orders::Show::Adjustments::Index::Adjustment::SpreeTaxRate::Component < SolidusAdmin::Orders::Show::Adjustments::Index::Adjustment::Component
  def icon
    "percent-line"
  end

  def detail
    link_to("#{model_name}: #{zone_name}", spree.edit_admin_tax_rate_path(adjustment.source_id), class: "body-link")
  end

  private

  def zone_name
    source.zone&.name || t("spree.all_zones")
  end
end
