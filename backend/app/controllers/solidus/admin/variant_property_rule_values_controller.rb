# frozen_string_literal: true

module Solidus
  module Admin
    class VariantPropertyRuleValuesController < ResourceController
      belongs_to 'solidus/product', find_by: :slug
    end
  end
end
