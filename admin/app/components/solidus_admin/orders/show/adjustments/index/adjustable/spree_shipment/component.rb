# frozen_string_literal: true

class SolidusAdmin::Orders::Show::Adjustments::Index::Adjustable::SpreeShipment::Component < SolidusAdmin::Orders::Show::Adjustments::Index::Adjustable::Component
  def caption
    "#{t("spree.shipment")} ##{adjustable.number}"
  end

  def detail
    link_to(
      adjustable.shipping_method.name,
      spree.edit_admin_shipping_method_path(adjustable.shipping_method),
      class: "body-link"
    )
  end
end
