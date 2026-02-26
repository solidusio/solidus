# frozen_string_literal: true

module Spree::RansackableAttributes
  extend ActiveSupport::Concern

  included do
    class_attribute :allowed_ransackable_associations, default: []
    class_attribute :allowed_ransackable_attributes, default: []
    class_attribute :allowed_ransackable_scopes, default: []
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
