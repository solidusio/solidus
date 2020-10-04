# frozen_string_literal: true

module Spree::RansackableAttributes
  extend ActiveSupport::Concern
  included do
    class_attribute :whitelisted_ransackable_associations
    class_attribute :whitelisted_ransackable_attributes

    class_attribute :default_ransackable_attributes
    self.default_ransackable_attributes = %w[id]
  end

  class_methods do
    def ransackable_associations(*_args)
      whitelisted_ransackable_associations || []
    end

    def ransackable_attributes(*_args)
      default_ransackable_attributes | (whitelisted_ransackable_attributes || [])
    end
  end
end
