# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::RansackableAttributes do
  let(:test_class) { Class.new(Spree::Base) }

  context "class attributes" do
    context "whitelisted_ransackable_associations" do
      it "is deprecated but working" do
        expect(Spree::Deprecation).to receive(:warn)
        test_class.allowed_ransackable_associations = ["test"]

        result = test_class.whitelisted_ransackable_associations

        expect(result).to match_array(["test"])
        expect(test_class.ransackable_associations).to match_array(["test"])
      end
    end

    context "whitelisted_ransackable_associations=" do
      it "is deprecated but working" do
        expect(Spree::Deprecation).to receive(:warn)

        test_class.whitelisted_ransackable_associations = ["new_value"]

        expect(test_class.allowed_ransackable_associations).to match_array(["new_value"])
        expect(test_class.ransackable_associations).to match_array(["new_value"])
      end
    end

    context "whitelisted_ransackable_associations.concat" do
      it "is deprecated but working" do
        expect(Spree::Deprecation).to receive(:warn)
        test_class.allowed_ransackable_associations = ["test"]

        test_class.whitelisted_ransackable_associations.concat(["new_value"])

        expect(test_class.allowed_ransackable_associations).to match_array(["test", "new_value"])
        expect(test_class.ransackable_associations).to match_array(["test", "new_value"])
      end
    end

    context "whitelisted_ransackable_attributes" do
      it "is deprecated but working" do
        expect(Spree::Deprecation).to receive(:warn)
        test_class.allowed_ransackable_attributes = []

        result = test_class.whitelisted_ransackable_attributes

        expect(result).to be_empty
        expect(test_class.ransackable_attributes).to match_array(["id"])
      end
    end

    context "whitelisted_ransackable_attributes=" do
      it "is deprecated but working" do
        expect(Spree::Deprecation).to receive(:warn)

        test_class.whitelisted_ransackable_attributes = ["new_value"]

        expect(test_class.allowed_ransackable_attributes).to match_array(["new_value"])
        expect(test_class.ransackable_attributes).to match_array(["id", "new_value"])
      end
    end

    context "whitelisted_ransackable_attributes.concat" do
      it "is deprecated but working" do
        expect(Spree::Deprecation).to receive(:warn)
        test_class.allowed_ransackable_attributes = ["test"]

        test_class.whitelisted_ransackable_attributes.concat(["new_value"])

        expect(test_class.allowed_ransackable_attributes).to match_array(["test", "new_value"])
        expect(test_class.ransackable_attributes).to match_array(["id", "test", "new_value"])
      end
    end

    context "allowed_ransackable_scopes" do
      before do
        test_class.allowed_ransackable_scopes = []
      end

      it 'reads' do
        expect(test_class.allowed_ransackable_scopes).to be_empty
      end

      it 'allows setting an array' do
        test_class.allowed_ransackable_scopes = [:test]
        expect(test_class.allowed_ransackable_scopes).to match_array([:test])
      end

      it 'allows concatenating' do
        test_class.allowed_ransackable_scopes.concat([:new_value])
        expect(test_class.allowed_ransackable_scopes).to match_array([:new_value])
      end
    end
  end
end
