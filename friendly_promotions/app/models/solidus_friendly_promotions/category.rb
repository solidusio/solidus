# frozen_string_literal: true

module SolidusFriendlyPromotions
  class Category < Spree::Base
    has_many :promotions

    validates :name, presence: true
  end
end
