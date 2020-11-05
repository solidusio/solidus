# frozen_string_literal: true

module Spree
  module Backend
    module Callbacks
      extend ActiveSupport::Concern

      module ClassMethods
        attr_accessor :callbacks

        protected

        def new_action
          @callbacks ||= {}
          @callbacks[:new_action] ||= Spree::ActionCallbacks.new
        end

        def create
          @callbacks ||= {}
          @callbacks[:create] ||= Spree::ActionCallbacks.new
        end

        def update
          @callbacks ||= {}
          @callbacks[:update] ||= Spree::ActionCallbacks.new
        end

        def destroy
          @callbacks ||= {}
          @callbacks[:destroy] ||= Spree::ActionCallbacks.new
        end

        def custom_callback(action)
          @callbacks ||= {}
          @callbacks[action] ||= Spree::ActionCallbacks.new
        end
      end

      protected

      def invoke_callbacks(action, callback_type)
        callbacks = self.class.callbacks || {}
        return if callbacks[action].nil?

        callback_list = "#{callback_type}_methods"
        return unless callbacks[action].respond_to?(callback_list)

        callback_type.send_public(callback_list).each { |method| send method }
      end
    end
  end
end
