# frozen_string_literal: true

module Spree
  module Admin
    class VariantPropertyRuleValuesController < ResourceController
      belongs_to 'spree/product', find_by: :slug
    end
  end
end
