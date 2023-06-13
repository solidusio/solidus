# frozen_string_literal: true

module SolidusFriendlyPromotions
  class Configuration < Spree::Preferences::Configuration
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
