# frozen_string_literal: true

module Spree
  module TestingSupport
    # A module providing convenience methods to test Solidus controllers
    # in Rails controller/functional tests. Possibly from inside an
    # application with a mounted Solidus engine.
    #
    # *There is generaly no need* to use this module. Instead, in
    # a functional/controller test against a Spree controller, just
    # use standard Rails functionality by including:
    #
    #   routes { Spree::Core::Engine.routes }
    #
    # And then use standard Rails test `get`, `post` etc methods.
    #
    # But some legacy code uses this ControllerRequests helper. It must
    # be included only in tests against Spree controllers, it will interfere
    # with tests against local app or other engine controllers, resulting
    # in ActionController::UrlGenerationError.
    #
    # To use this module, inside your spec_helper.rb, include this module inside
    # the RSpec.configure block by:
    #
    #   require 'spree/testing_support/controller_requests'
    #   RSpec.configure do |c|
    #     c.include Spree::TestingSupport::ControllerRequests, spree_controller: true
    #   end
    #
    # Then, in your controller tests against spree controllers, you can access
    # tag to use this module, and access spree routes like this:
    #
    #   require 'spec_helper'
    #
    #   describe Spree::ProductsController, :spree_controller do
    #     it "can see all the products" do
    #       spree_get :index
    #     end
    #   end
    #
    # Use spree_get, spree_post, spree_put or spree_delete to make requests to
    # the Spree engine, and use regular get, post, put or delete to make
    # requests to your application.
    module ControllerRequests
      extend ActiveSupport::Concern

      included do
        routes { Spree::Core::Engine.routes }
      end

      def spree_get(action, parameters = nil, session = nil, flash = nil)
        process_spree_action(action, parameters, session, flash, "GET")
      end
      deprecate spree_get: :get, deprecator: Spree::Deprecation

      # Executes a request simulating POST HTTP method and set/volley the response
      def spree_post(action, parameters = nil, session = nil, flash = nil)
        process_spree_action(action, parameters, session, flash, "POST")
      end
      deprecate spree_post: :post, deprecator: Spree::Deprecation

      # Executes a request simulating PUT HTTP method and set/volley the response
      def spree_put(action, parameters = nil, session = nil, flash = nil)
        process_spree_action(action, parameters, session, flash, "PUT")
      end
      deprecate spree_put: :put, deprecator: Spree::Deprecation

      # Executes a request simulating DELETE HTTP method and set/volley the response
      def spree_delete(action, parameters = nil, session = nil, flash = nil)
        process_spree_action(action, parameters, session, flash, "DELETE")
      end
      deprecate spree_delete: :delete, deprecator: Spree::Deprecation

      def spree_xhr_get(action, parameters = nil, session = nil, flash = nil)
        process_spree_xhr_action(action, parameters, session, flash, :get)
      end
      deprecate spree_xhr_get: :get, deprecator: Spree::Deprecation

      def spree_xhr_post(action, parameters = nil, session = nil, flash = nil)
        process_spree_xhr_action(action, parameters, session, flash, :post)
      end
      deprecate spree_xhr_post: :post, deprecator: Spree::Deprecation

      def spree_xhr_put(action, parameters = nil, session = nil, flash = nil)
        process_spree_xhr_action(action, parameters, session, flash, :put)
      end
      deprecate spree_xhr_put: :put, deprecator: Spree::Deprecation

      def spree_xhr_delete(action, parameters = nil, session = nil, flash = nil)
        process_spree_xhr_action(action, parameters, session, flash, :delete)
      end
      deprecate spree_xhr_delete: :delete, deprecator: Spree::Deprecation

      private

      def process_spree_action(action, parameters = nil, session = nil, flash = nil, method = "GET")
        parameters ||= {}
        process(action, method, parameters, session, flash)
      end

      def process_spree_xhr_action(action, parameters = nil, session = nil, flash = nil, method = :get)
        parameters ||= {}
        parameters.reverse_merge!(format: :json)
        xml_http_request(method, action, parameters, session, flash)
      end
    end
  end
end
