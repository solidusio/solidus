module Spree
  module Admin
    class VariantImageRuleValuesController < ResourceController
      belongs_to 'spree/product', find_by: :slug
    end
  end
end
