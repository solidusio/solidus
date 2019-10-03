# frozen_string_literal: true

module Solidus
  class PromotionCategory < Solidus::Base
    validates_presence_of :name
    has_many :promotions
  end
end
