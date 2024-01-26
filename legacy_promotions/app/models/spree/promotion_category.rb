# frozen_string_literal: true

module Spree
  class PromotionCategory < Spree::Base
    validates_presence_of :name
    has_many :promotions
  end
end
