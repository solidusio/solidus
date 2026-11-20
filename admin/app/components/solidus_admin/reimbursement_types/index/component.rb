# frozen_string_literal: true

class SolidusAdmin::ReimbursementTypes::Index::Component < SolidusAdmin::RefundsAndReturns::Component
  def model_class = Spree::ReimbursementType

  def search_url = solidus_admin.reimbursement_types_path

  def search_key = :name_cont

  def edit_path(reimbursement_type)
    solidus_admin.edit_reimbursement_type_path(reimbursement_type, **search_filter_params)
  end

  def turbo_frames = %w[resource_form]

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t(".add"),
      href: solidus_admin.new_reimbursement_type_path(**search_filter_params),
      data: {turbo_frame: :resource_form},
      icon: "add-line",
      class: "align-self-end w-full"
    )
  end

  def batch_actions
    [
      {
        label: t(".batch_actions.delete"),
        action: solidus_admin.reimbursement_types_path(**search_filter_params),
        method: :delete,
        icon: "delete-bin-7-line"
      }
    ]
  end

  def columns
    [
      {
        header: :name,
        data: ->(reimbursement_type) do
          link_to reimbursement_type.name, edit_path(reimbursement_type),
            data: {turbo_frame: :resource_form},
            class: "body-link"
        end
      },
      {
        header: :active,
        data: ->(reimbursement_type) do
          reimbursement_type.active? ? component("ui/badge").yes : component("ui/badge").no
        end
      }
    ]
  end
end
