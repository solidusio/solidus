# frozen_string_literal: true

class SolidusAdmin::StoreCreditReasons::Index::Component < SolidusAdmin::RefundsAndReturns::Component
  def model_class
    Spree::StoreCreditReason
  end

  def actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: spree.new_admin_store_credit_reason_path,
      icon: "add-line",
      class: "align-self-end w-full",
    )
  end

  def row_url(store_credit_reason)
    spree.edit_admin_store_credit_reason_path(store_credit_reason)
  end

  def search_url
    solidus_admin.store_credit_reasons_path
  end

  def search_key
    :name_cont
  end

  def batch_actions
    [
      {
        label: t('.batch_actions.delete'),
        action: solidus_admin.store_credit_reasons_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def columns
    [
      :name,
      {
        header: :active,
        data: ->(store_credit_reason) do
          store_credit_reason.active? ? component('ui/badge').yes : component('ui/badge').no
        end
      },
    ]
  end
end
