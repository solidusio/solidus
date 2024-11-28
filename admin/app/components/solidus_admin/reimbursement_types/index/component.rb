# frozen_string_literal: true

class SolidusAdmin::ReimbursementTypes::Index::Component < SolidusAdmin::RefundsAndReturns::Component
  def model_class
    Spree::ReimbursementType
  end

  def search_url
    solidus_admin.reimbursement_types_path
  end

  def search_key
    :name_cont
  end

  def columns
    [
      {
        header: :name,
        data: ->(reimbursement_type) do
          reimbursement_type.name
        end
      },
      {
        header: :active,
        data: ->(reimbursement_type) do
          reimbursement_type.active? ? component('ui/badge').yes : component('ui/badge').no
        end
      },
    ]
  end
end
