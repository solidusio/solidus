module Spree
  class ReturnAuthorizationReason < ActiveRecord::Base
    include Spree::NamedType

    has_many :return_authorizations
  end
end
