# frozen_string_literal: true

module Spree
  module NullPromotionFinder
    def self.by_code_or_id(*)
      raise ActiveRecord::RecordNotFound, "No promotion system configured."
    end
  end
end
