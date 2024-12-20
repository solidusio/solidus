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

  def edit_path(return_reason)
    spree.edit_admin_return_reason_path(return_reason, **search_filter_params)
  end

  def turbo_frames
    %w[
      resource_modal
    ]
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: solidus_admin.new_return_reason_path(**search_filter_params),
      data: { turbo_frame: :resource_modal },
      icon: "add-line",
      class: "align-self-end w-full",
    )
  end

  def batch_actions
    [
      {
        label: t('.batch_actions.delete'),
        action: solidus_admin.return_reasons_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def columns
    [
      {
        header: :name,
        data: ->(return_reason) do
          link_to return_reason.name, edit_path(return_reason),
            data: { turbo_frame: :resource_modal },
            class: 'body-link'
        end
      },
      {
        header: :active,
        data: ->(return_reason) do
          return_reason.active? ? component('ui/badge').yes : component('ui/badge').no
        end
      },
    ]
  end
end
