# frozen_string_literal: true

module Spree::RansackableAttributes
  extend ActiveSupport::Concern
  included do
    class_attribute :allowed_ransackable_associations, default: []
    class_attribute :allowed_ransackable_attributes, default: []
    class_attribute :allowed_ransackable_scopes, default: []

    def self.whitelisted_ransackable_associations
      Spree::Deprecation.deprecation_warning(:whitelisted_ransackable_associations, 'use allowed_ransackable_associations instead')
      allowed_ransackable_associations
    end

    def self.whitelisted_ransackable_associations=(new_value)
      Spree::Deprecation.deprecation_warning(:whitelisted_ransackable_associations=, 'use allowed_ransackable_associations= instead')
      self.allowed_ransackable_associations = new_value
    end

    def self.whitelisted_ransackable_attributes
      Spree::Deprecation.deprecation_warning(:whitelisted_ransackable_attributes, 'use allowed_ransackable_attributes instead')
      allowed_ransackable_attributes
    end

    def self.whitelisted_ransackable_attributes=(new_value)
      Spree::Deprecation.deprecation_warning(:whitelisted_ransackable_attributes=, 'use allowed_ransackable_attributes= instead')
      self.allowed_ransackable_attributes = new_value
    end

    class_attribute :default_ransackable_attributes
    self.default_ransackable_attributes = %w[id]
  end

  class_methods do
    def ransackable_associations(*_args)
      allowed_ransackable_associations
    end

    def ransackable_attributes(*_args)
      default_ransackable_attributes | allowed_ransackable_attributes
    end

    def ransackable_scopes(*_args)
      allowed_ransackable_scopes
    end
  end
end
