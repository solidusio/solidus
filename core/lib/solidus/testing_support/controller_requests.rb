module Spree
  module TestingSupport
    # Use this module to easily test Spree actions within Spree components or
    # inside your application to test routes for the mounted Spree engine.
    #
    # Inside your spec_helper.rb, include this module inside the
    # RSpec.configure block by doing this:
    #
    #   require 'solidus/testing_support/controller_requests'
    #   RSpec.configure do |c|
    #     c.include Solidus::TestingSupport::ControllerRequests, :type => :controller
    #   end
    #
    # Then, in your controller tests, you can access solidus routes like this:
    #
    #   require 'spec_helper'
    #
    #   describe Solidus::ProductsController do
    #     it "can see all the products" do
    #       solidus_get :index
    #     end
    #   end
    #
    # Use solidus_get, solidus_post, solidus_put or solidus_delete to make requests to
    # the Spree engine, and use regular get, post, put or delete to make
    # requests to your application.
    module ControllerRequests
      extend ActiveSupport::Concern

      included do
        routes { Solidus::Core::Engine.routes }
      end

      def solidus_get(action, parameters = nil, session = nil, flash = nil)
        process_solidus_action(action, parameters, session, flash, "GET")
      end

      # Executes a request simulating POST HTTP method and set/volley the response
      def solidus_post(action, parameters = nil, session = nil, flash = nil)
        process_solidus_action(action, parameters, session, flash, "POST")
      end

      # Executes a request simulating PUT HTTP method and set/volley the response
      def solidus_put(action, parameters = nil, session = nil, flash = nil)
        process_solidus_action(action, parameters, session, flash, "PUT")
      end

      # Executes a request simulating DELETE HTTP method and set/volley the response
      def solidus_delete(action, parameters = nil, session = nil, flash = nil)
        process_solidus_action(action, parameters, session, flash, "DELETE")
      end

      def solidus_xhr_get(action, parameters = nil, session = nil, flash = nil)
        process_solidus_xhr_action(action, parameters, session, flash, :get)
      end

      def solidus_xhr_post(action, parameters = nil, session = nil, flash = nil)
        process_solidus_xhr_action(action, parameters, session, flash, :post)
      end

      def solidus_xhr_put(action, parameters = nil, session = nil, flash = nil)
        process_solidus_xhr_action(action, parameters, session, flash, :put)
      end

      def solidus_xhr_delete(action, parameters = nil, session = nil, flash = nil)
        process_solidus_xhr_action(action, parameters, session, flash, :delete)
      end

      private

      def process_solidus_action(action, parameters = nil, session = nil, flash = nil, method = "GET")
        parameters ||= {}
        process(action, method, parameters, session, flash)
      end

      def process_solidus_xhr_action(action, parameters = nil, session = nil, flash = nil, method = :get)
        parameters ||= {}
        parameters.reverse_merge!(:format => :json)
        xml_http_request(method, action, parameters, session, flash)
      end
    end
  end
end
