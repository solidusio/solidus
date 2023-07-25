# frozen_string_literal: true

require 'spree/core/environment_extension'

module SolidusFriendlyPromotions
  class Configuration < Spree::Preferences::Configuration
    include Spree::Core::EnvironmentExtension

    add_class_set :line_item_discount_calculators
    add_class_set :shipment_discount_calculators

    add_class_set :order_rules
    add_class_set :line_item_rules
    add_class_set :shipment_rules

    add_class_set :actions
    add_class_set :discounters

    class_name_attribute :discount_chooser_class, default: "SolidusFriendlyPromotions::PromotionAdjustmentChooser"
    class_name_attribute :promotion_code_batch_mailer_class,
      default: "SolidusFriendlyPromotions::PromotionCodeBatchMailer"

    # @!attribute [rw] promotions_per_page
    #   @return [Integer] Promotions to show per-page in the admin (default: +25+)
    preference :promotions_per_page, :integer, default: 25
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    alias_method :config, :configuration

    def configure
      yield configuration
    end
  end
end
