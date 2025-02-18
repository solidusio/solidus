# frozen_string_literal: true

require "active_support/deprecation"

module Spree
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
      @method_or_var = method_or_var
      @var = var
      @deprecator = deprecator
      @message = message
    end

    private

    def target
      return @instance.instance_variable_get(@method_or_var) if @instance.instance_variable_defined?(@method_or_var)

      @instance.__send__(@method_or_var)
    end

    def warn(callstack, called, args)
      message = @message || "#{@var} is deprecated! Call #{@method_or_var}.#{called} instead of #{@var}.#{called}."
      message = [message, "Args: #{args.inspect}"].join(" ") unless args.empty?

      @deprecator.warn(message, callstack)
    end
  end
end
