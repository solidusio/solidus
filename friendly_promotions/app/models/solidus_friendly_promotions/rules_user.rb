# frozen_string_literal: true

module SolidusFriendlyPromotions
  class RulesUser < Spree::Base
    belongs_to :rule
    belongs_to :user, class_name: Spree::UserClassHandle.new
  end
end
