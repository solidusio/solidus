module Spree
  class ReturnAuthorizationReason < Spree::Base
    include Spree::NamedType

    has_many :return_authorizations

    def self.reasons_for_return_items(return_items)
      reasons = Spree::ReturnAuthorizationReason.active
      # Only allow an inactive reason if it's already associated to a return item
      return_items.each do |return_item|
        if return_item.return_authorization_reason && !return_item.return_authorization_reason.active?
          reasons << return_item.return_authorization_reason
        end
      end
      reasons
    end
  end
end
