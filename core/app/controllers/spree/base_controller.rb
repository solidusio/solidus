# frozen_string_literal: true

require "cancan"
require_dependency "spree/core/controller_helpers/strong_parameters"

class Spree::BaseController < ApplicationController
  include ActiveStorage::SetCurrent
  include Spree::Core::ControllerHelpers::Auth
  include Spree::Core::ControllerHelpers::Common
  include Spree::Core::ControllerHelpers::PaymentParameters
  include Spree::Core::ControllerHelpers::Search
  include Spree::Core::ControllerHelpers::Store
  include Spree::Core::ControllerHelpers::StrongParameters
end
