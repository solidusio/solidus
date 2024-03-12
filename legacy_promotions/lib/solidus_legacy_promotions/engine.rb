# frozen_string_literal: true

module SolidusLegacyPromotions
  class Engine < ::Rails::Engine
    include SolidusSupport::EngineExtensions

    initializer "solidus_legacy_promotions", after: "spree.load_config_initializers" do
      Spree::Config.order_contents_class = "Spree::OrderContents"
      Spree::Config.promotion_configuration_class = "Spree::Core::PromotionConfiguration"
      Spree::Config.adjustment_promotion_source_types << "Spree::PromotionAction"
      Spree::Config.promotion_configuration_class = "Spree::Core::PromotionConfiguration"
    end
  end
end
