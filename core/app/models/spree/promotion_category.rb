module Spree
  class PromotionCategory < ActiveRecord::Base
    validates_presence_of :name
    has_many :promotions
  end
end
