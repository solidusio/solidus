# frozen_string_literal: true

class SolidusAdmin::RefundReasons::Index::Component < SolidusAdmin::RefundsAndReturns::Component
  def model_class
    Spree::RefundReason
  end

  def search_url
    solidus_admin.refund_reasons_path
  end

  def search_key
    :name_or_code_cont
  end

  def edit_path(refund_reason)
    spree.edit_admin_refund_reason_path(refund_reason, **search_filter_params)
  end

  def turbo_frames
    %w[
      resource_modal
    ]
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t(".add"),
      href: solidus_admin.new_refund_reason_path(**search_filter_params),
      data: {turbo_frame: :resource_modal},
      icon: "add-line",
      class: "align-self-end w-full"
    )
  end

  def batch_actions
    [
      {
        label: t(".batch_actions.delete"),
        action: solidus_admin.refund_reasons_path(**search_filter_params),
        method: :delete,
        icon: "delete-bin-7-line"
      }
    ]
  end

  def columns
    [
      {
        header: :name,
        data: ->(refund_reason) do
          link_to refund_reason.name, edit_path(refund_reason),
            data: {turbo_frame: :resource_modal},
            class: "body-link"
        end
      },
      {
        header: :code,
        data: ->(refund_reason) do
          link_to_if refund_reason.code, refund_reason.code, edit_path(refund_reason),
            data: {turbo_frame: :resource_modal},
            class: "body-link"
        end
      },
      {
        header: :active,
        data: ->(refund_reason) do
          refund_reason.active? ? component("ui/badge").yes : component("ui/badge").no
        end
      }
    ]
  end
end
