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

  def row_url(refund_reason)
    spree.edit_admin_refund_reason_path(refund_reason, _turbo_frame: :edit_refund_reason_modal)
  end

  def turbo_frames
    %w[
      new_refund_reason_modal
      edit_refund_reason_modal
    ]
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: solidus_admin.new_refund_reason_path, data: { turbo_frame: :new_refund_reason_modal },
      icon: "add-line",
      class: "align-self-end w-full",
    )
  end

  def batch_actions
    [
      {
        label: t('.batch_actions.delete'),
        action: solidus_admin.refund_reasons_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def columns
    [
      :name,
      :code,
      {
        header: :active,
        data: ->(refund_reason) do
          refund_reason.active? ? component('ui/badge').yes : component('ui/badge').no
        end
      },
    ]
  end
end
