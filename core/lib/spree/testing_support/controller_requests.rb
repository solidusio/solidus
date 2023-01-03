# frozen_string_literal: true

module Spree
  module TestingSupport
    # *There is generaly no need* to use this module. Instead, in
    # a functional/controller test against a Spree controller, just
    # use standard Rails functionality by including:
    #
    #   routes { Spree::Core::Engine.routes }
    #
    # To use this module, inside your spec_helper.rb, include this module inside
    # the RSpec.configure block by:
    #
    #   require 'spree/testing_support/controller_requests'
    #   RSpec.configure do |c|
    #     c.include Spree::TestingSupport::ControllerRequests, spree_controller: true
    #   end
    module ControllerRequests
      extend ActiveSupport::Concern

      included do
        routes { Spree::Core::Engine.routes }
      end
    end
  end
end

