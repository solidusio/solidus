# frozen_string_literal: true

module SolidusPromotions
  class PromotionCategory < Spree::Base
    has_many :promotions, dependent: :nullify

    validates :name, presence: true
  end
end
