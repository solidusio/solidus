# frozen_string_literal: true

module Spree
  class Settlement < Spree::Base
    module EligibilityValidator
      class BaseValidator
        attr_reader :errors

        def initialize(settlement)
          @settlement = settlement
          @errors = {}
        end

        def eligible_for_settlement?
          raise NotImplementedError, I18n.t('spree.implement_eligible_for_settlement')
        end

        def requires_manual_intervention?
          raise NotImplementedError, I18n.t('spree.implement_requires_manual_intervention')
        end

        private

        def add_error(key, error)
          @errors[key] = error
        end
      end
    end
  end
end
