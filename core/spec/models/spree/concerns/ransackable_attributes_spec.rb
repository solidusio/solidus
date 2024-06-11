# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::RansackableAttributes do
  let(:test_class) { Class.new(Spree::Base) }

  context "class attributes" do
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
