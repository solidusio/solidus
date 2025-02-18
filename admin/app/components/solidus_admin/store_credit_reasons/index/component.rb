# frozen_string_literal: true

class SolidusAdmin::StoreCreditReasons::Index::Component < SolidusAdmin::RefundsAndReturns::Component
  def model_class
    Spree::StoreCreditReason
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t(".add"),
      href: solidus_admin.new_store_credit_reason_path(**search_filter_params),
      data: {turbo_frame: :resource_modal},
      icon: "add-line",
      class: "align-self-end w-full"
    )
  end

  def turbo_frames
    %w[
      resource_modal
    ]
  end

  def edit_path(store_credit_reason)
    spree.edit_admin_store_credit_reason_path(store_credit_reason, **search_filter_params)
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
        label: t(".batch_actions.delete"),
        action: solidus_admin.store_credit_reasons_path(**search_filter_params),
        method: :delete,
        icon: "delete-bin-7-line"
      }
    ]
  end

  def columns
    [
      {
        header: :name,
        data: ->(store_credit_reason) do
          link_to store_credit_reason.name, edit_path(store_credit_reason),
            data: {turbo_frame: :resource_modal},
            class: "body-link"
        end
      },
      {
        header: :active,
        data: ->(store_credit_reason) do
          store_credit_reason.active? ? component("ui/badge").yes : component("ui/badge").no
        end
      }
    ]
  end
end
