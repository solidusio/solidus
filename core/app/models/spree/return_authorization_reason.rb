module Spree
  class ReturnAuthorizationReason < ActiveRecord::Base
    include Spree::ReasonType

    has_many :return_authorizations
  end
end
