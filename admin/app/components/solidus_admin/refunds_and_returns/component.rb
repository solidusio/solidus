# frozen_string_literal: true

class SolidusAdmin::RefundsAndReturns::Component < SolidusAdmin::UI::Pages::Index::Component
  def title
    page_header_title safe_join([
      tag.div(t(".title")),
      tag.div(t(".subtitle"), class: "font-normal text-sm text-gray-500")
    ])
  end

  def tabs
    [
      {
        text: Spree::RefundReason.model_name.human(count: 2),
        href: solidus_admin.refund_reasons_path,
        current: model_class == Spree::RefundReason
      },
      {
        text: Spree::ReimbursementType.model_name.human(count: 2),
        href: solidus_admin.reimbursement_types_path,
        current: model_class == Spree::ReimbursementType
      },
      {
        text: Spree::ReturnReason.model_name.human(count: 2),
        href: solidus_admin.return_reasons_path,
        current: model_class == Spree::ReturnReason
      },
      {
        text: Spree::AdjustmentReason.model_name.human(count: 2),
        href: solidus_admin.adjustment_reasons_path,
        current: model_class == Spree::AdjustmentReason
      },
      {
        text: Spree::StoreCreditReason.model_name.human(count: 2),
        href: solidus_admin.store_credit_reasons_path,
        current: model_class == Spree::StoreCreditReason
      }
    ]
  end
end
