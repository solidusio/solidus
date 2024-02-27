# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::AppConfiguration do
  let(:prefs) { Spree::Config }

  describe "#adjustment_promotion_source_types" do
    subject { prefs.adjustment_promotion_source_types }

    it { is_expected.to contain_exactly(Spree::PromotionAction) }
  end

  context "deprecated preferences" do
    around do |example|
      Spree.deprecator.silence do
        example.run
      end
    end

    it "uses order adjustments recalculator class by default" do
      expect(prefs.promotion_adjuster_class).to eq Spree::Promotion::OrderAdjustmentsRecalculator
    end

    it "uses promotion handler coupon class by default" do
      expect(prefs.coupon_code_handler_class).to eq Spree::PromotionHandler::Coupon
    end

    it "uses promotion handler shipping class by default" do
      expect(prefs.shipping_promotion_handler_class).to eq Spree::PromotionHandler::Shipping
    end

    it "uses promotion code batch mailer class by default" do
      expect(prefs.promotion_code_batch_mailer_class).to eq Spree::PromotionCodeBatchMailer
    end

    it "uses promotion chooser class by default" do
      expect(prefs.promotion_chooser_class).to eq Spree::PromotionChooser
    end

    context "config.environment" do
      class DummyClass; end
      let(:environment) { prefs.environment }

      shared_examples "working preferences set" do
        it "allows adding new items" do
          preferences_set << DummyClass
          expect(preferences_set).to include DummyClass
          preferences_set.delete DummyClass
        end
      end

      context ".calculators" do
        subject(:calculators) { environment.calculators }
        it { is_expected.to be_a Spree::Core::Environment::Calculators }

        context ".calculators.promotion_actions_create_adjustments" do
          subject(:preferences_set) { calculators.promotion_actions_create_adjustments }
          it_should_behave_like "working preferences set"
        end

        context ".calculators.promotion_actions_create_item_adjustments" do
          subject(:preferences_set) { calculators.promotion_actions_create_item_adjustments }
          it_should_behave_like "working preferences set"
        end

        context ".calculators.promotion_actions_create_quantity_adjustments" do
          subject(:preferences_set) { calculators.promotion_actions_create_quantity_adjustments }
          it_should_behave_like "working preferences set"
        end
      end

      context ".promotions" do
        subject(:promotions) { environment.promotions }

        it { is_expected.to be_a Spree::Core::Environment::Promotions }

        context ".promotions.rules" do
          subject(:preferences_set) { promotions.rules }
          it_should_behave_like "working preferences set"
        end

        context ".promotions.actions" do
          subject(:preferences_set) { promotions.actions }
          it_should_behave_like "working preferences set"
        end

        context ".promotions.shipping_actions" do
          subject(:preferences_set) { promotions.shipping_actions }
          it_should_behave_like "working preferences set"
        end
      end
    end
  end
end
