# frozen_string_literal: true

require 'responders'
require 'spree/api/responders/jbuilder_template'

module Spree
  module Api
    module Responders
      class AppResponder < ActionController::Responder
        include JbuilderTemplate
      end
    end
  end
end
