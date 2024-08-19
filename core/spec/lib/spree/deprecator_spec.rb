# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Spree.deprecator" do
  Dummy = Class.new do
    def deprecated_method
      "foo"
    end
    deprecate :deprecated_method, deprecator: Spree.deprecator
  end

  context "by default" do
    it "returns a valid deprecator" do
      expect(Spree.deprecator).to have_attributes(
        deprecation_horizon: "5.0",
        gem_name: "Solidus"
      )
    end

    it "does not raise an error unless overridden by environment" do
      if ENV["SOLIDUS_RAISE_DEPRECATIONS"]
        expect { Dummy.new.deprecated_method }.to raise_error(ActiveSupport::DeprecationException)
      else
        expect { Dummy.new.deprecated_method }.not_to raise_error
      end
    end
  end

  context "when the behavior has been changed to :raise" do
    around do |example|
      behavior_name = ActiveSupport::Deprecation::DEFAULT_BEHAVIORS.detect { |_behavior_name, behavior_proc|
        behavior_proc == Spree.deprecator.behavior.first
      }.first

      Spree.deprecator.behavior = :raise

      example.run

      Spree.deprecator.behavior = behavior_name
    end

    it "raises an error when a deprecated method is called" do
      expect { Dummy.new.deprecated_method }
        .to raise_error(ActiveSupport::DeprecationException)
    end
  end
end
