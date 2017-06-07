module Spree
  class SpreeError < StandardError
  end

  class BillingConnectionError < SpreeError
    attr_reader :triggering_exception

    def initialize(message, triggering_exception)
      super(message)
      @triggering_exception = triggering_exception
    end
  end
end
