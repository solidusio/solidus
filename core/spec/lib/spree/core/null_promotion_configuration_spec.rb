# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Core::NullPromotionConfiguration do
  subject(:config) { described_class.new }

  it "uses the null promotion adjuster class by default" do
    expect(config.order_adjuster_class).to eq Spree::NullPromotionAdjuster
  end

  it "uses the null coupon code handler class by default" do
    expect(config.coupon_code_handler_class).to eq Spree::NullPromotionHandler
  end

  it "uses the null promotion finder class by default" do
    expect(config.promotion_finder_class).to eq Spree::NullPromotionFinder
  end

  it "uses the null promotion handler as the shipping promo handler" do
    Spree.deprecator.silence do
      expect(config.shipping_promotion_handler_class).to eq Spree::NullPromotionHandler
    end
  end

  it "uses the null promotion advertiser class by default" do
    expect(config.advertiser_class).to eq Spree::NullPromotionAdvertiser
  end

  it "uses the deprecated configurable class for promotion code batch mailer" do
    Spree.deprecator.silence do
      expect(config.promotion_code_batch_mailer_class).to eq Spree::DeprecatedConfigurableClass
    end
  end

  it "uses the deprecated configurable class for promotion chooser" do
    Spree.deprecator.silence do
      expect(config.promotion_chooser_class).to eq Spree::DeprecatedConfigurableClass
    end
  end

  it "has a setter for a set of rules" do
    Spree.deprecator.silence do
      expect { config.rules = ["Spree::PromotionRule"] }.not_to raise_error
    end
  end

  it "has a getter for a set of rules" do
    Spree.deprecator.silence do
      expect(config.rules).to be_empty
    end
  end

  it "has a setter for a set of actions" do
    Spree.deprecator.silence do
      expect { config.actions = ["Spree::PromotionAction"] }.not_to raise_error
    end
  end

  it "has a setter for a set of shipping actions" do
    Spree.deprecator.silence do
      expect { config.shipping_actions = ["Spree::PromotionAction"] }.not_to raise_error
    end
  end

  it "has a getter for a set of actions" do
    Spree.deprecator.silence do
      expect(config.actions).to be_empty
    end
  end

  it "has deprecated nested class set for calculcators" do
    Spree.deprecator.silence do
      expect { config.calculators["Spree::PromotionAction"] = ["Spree::Calculator"] }.not_to raise_error
      expect { config.calculators["Spree::PromotionAction"] }.not_to raise_error
    end
  end
end
