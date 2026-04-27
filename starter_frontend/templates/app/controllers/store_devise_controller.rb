# frozen_string_literal: true

class StoreDeviseController < ApplicationController
  helper 'spree/base', 'spree/store'

  include Spree::Core::ControllerHelpers::Auth
  include Spree::Core::ControllerHelpers::Common
  include Spree::Core::ControllerHelpers::Order
  include Spree::Core::ControllerHelpers::Store
  include Taxonomies

  layout 'storefront'
end
