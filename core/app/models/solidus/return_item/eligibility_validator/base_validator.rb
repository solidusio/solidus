module Spree
  class Solidus::ReturnItem::EligibilityValidator::BaseValidator
    attr_reader :errors

    def initialize(return_item)
      @return_item = return_item
      @errors = {}
    end

    def eligible_for_return?
      raise NotImplementedError, Solidus.t(:implement_eligible_for_return)
    end

    def requires_manual_intervention?
      raise NotImplementedError, Solidus.t(:implement_requires_manual_intervention)
    end

    private

    def add_error(key, error)
      @errors[key] = error
    end
  end
end
