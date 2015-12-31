require 'solidus/api/responders/rabl_template'

module Solidus
  module Api
    module Responders
      class AppResponder < ActionController::Responder
        include RablTemplate
      end
    end
  end
end
