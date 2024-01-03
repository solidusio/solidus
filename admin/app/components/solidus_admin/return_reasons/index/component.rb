# frozen_string_literal: true

class SolidusAdmin::ReturnReasons::Index::Component < SolidusAdmin::RefundsAndReturns::Component
  def model_class
    Spree::ReturnReason
  end

  def search_url
    solidus_admin.return_reasons_path
  end

  def search_key
    :name_cont
  end

  def row_url(return_reason)
    spree.edit_admin_return_reason_path(return_reason)
  end

  def batch_actions
    [
      {
        display_name: t('.batch_actions.delete'),
        action: solidus_admin.return_reasons_path,
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
        data: ->(return_reason) do
          return_reason.active? ? component('ui/badge').yes : component('ui/badge').no
        end
      },
    ]
  end
end
