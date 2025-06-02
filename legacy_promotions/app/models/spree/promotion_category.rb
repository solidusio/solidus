# frozen_string_literal: true

module Spree
  class PromotionCategory < Spree::Base
    validates :name, presence: true
    has_many :promotions
  end
end
