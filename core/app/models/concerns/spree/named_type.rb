# frozen_string_literal: true

module Spree
  module NamedType
    extend ActiveSupport::Concern

    included do
      Spree.deprecator.warn "Spree::NamedType is deprecated. Please set scopes and validations locally instead.", caller

      scope :active, -> { where(active: true) }
      default_scope -> { order(arel_table[:name].lower) }

      validates :name, presence: true, uniqueness: { case_sensitive: false, allow_blank: true }
    end
  end
end
