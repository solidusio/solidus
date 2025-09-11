# frozen_string_literal: true

class SolidusAdmin::AdjustmentReasons::Index::Component < SolidusAdmin::RefundsAndReturns::Component
  def model_class
    Spree::AdjustmentReason
  end

  def search_url
    solidus_admin.adjustment_reasons_path
  end

  def search_key
    :name_or_code_cont
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t(".add"),
      href: solidus_admin.new_adjustment_reason_path(**search_filter_params),
      data: {turbo_frame: :resource_form},
      icon: "add-line",
      class: "align-self-end w-full"
    )
  end

  def turbo_frames
    %w[
      resource_form
    ]
  end

  def edit_path(adjustment_reason)
    spree.edit_admin_adjustment_reason_path(adjustment_reason, **search_filter_params)
  end

  def batch_actions
    [
      {
        label: t(".batch_actions.delete"),
        action: solidus_admin.adjustment_reasons_path(**search_filter_params),
        method: :delete,
        icon: "delete-bin-7-line"
      }
    ]
  end

  def columns
    [
      {
        header: :name,
        data: ->(adjustment_reason) do
          link_to adjustment_reason.name, edit_path(adjustment_reason),
            class: "body-link",
            data: {turbo_frame: :resource_form}
        end
      },
      {
        header: :code,
        data: ->(adjustment_reason) do
          link_to adjustment_reason.code, edit_path(adjustment_reason),
            class: "body-link",
            data: {turbo_frame: :resource_form}
        end
      },
      {
        header: :active,
        data: ->(adjustment_reason) do
          adjustment_reason.active? ? component("ui/badge").yes : component("ui/badge").no
        end
      }
    ]
  end
end
