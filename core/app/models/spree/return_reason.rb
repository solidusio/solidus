module Spree
  class ReturnReason < ActiveRecord::Base
    include Spree::NamedType

    has_many :return_authorizations

    def self.reasons_for_return_items(return_items)
      reasons = Spree::ReturnReason.active
      # Only allow an inactive reason if it's already associated to a return item
      return_items.each do |return_item|
        if return_item.return_reason && !return_item.return_reason.active?
          reasons << return_item.return_reason
        end
      end
      reasons
    end
  end
end
