# frozen_string_literal: true

require 'active_support/deprecation'

module Spree
  def self.deprecator
    @deprecator ||= ActiveSupport::Deprecation.new('5.0', 'Solidus')
  end

  Deprecation = Spree.deprecator

  # This DeprecatedInstanceVariableProxy transforms instance variable to
  # deprecated instance variable.
  #
  # It differs from ActiveSupport::DeprecatedInstanceVariableProxy since
  # it allows to define a custom message.
  #
  #   class Example
  #     def initialize(deprecator)
  #       @request = Spree::DeprecatedInstanceVariableProxy.new(self, :request, :@request, deprecator, "Please, do not use this thing.")
  #       @_request = :a_request
  #     end
  #
  #     def request
  #       @_request
  #     end
  #
  #     def old_request
  #       @request
  #     end
  #   end
  #
  # When someone execute any method on @request variable this will trigger
  # +warn+ method on +deprecator_instance+ and will fetch <tt>@_request</tt>
  # variable via +request+ method and execute the same method on non-proxy
  # instance variable.
  #
  # Default deprecator is <tt>Spree.deprecator</tt>.
  class DeprecatedInstanceVariableProxy < ActiveSupport::Deprecation::DeprecationProxy
    def initialize(instance, method_or_var, var = "@#{method}", deprecator = Spree.deprecator, message = nil)
      @instance = instance
      @method = method
      @var = var
      @deprecator = deprecator
      @message = message
    end

    private

    def target
      @instance.__send__(@method)
    end

    def warn(callstack, called, args)
      message = @message || "#{@var} is deprecated! Call #{@method}.#{called} instead of #{@var}.#{called}."
      message = [message, "Args: #{args.inspect}"].join(" ")

      @deprecator.warn(message, callstack)
    end
  end
end
