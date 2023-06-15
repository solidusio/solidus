# frozen_string_literal: true

require 'spree/core/environment_extension'

module SolidusFriendlyPromotions
  class Configuration < Spree::Preferences::Configuration
    include Spree::Core::EnvironmentExtension

    add_class_set :line_item_discount_calculators
    add_class_set :shipment_discount_calculators

    class_name_attribute :promotion_chooser_class, default: "SolidusFriendlyPromotions::PromotionAdjustmentChooser"
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
