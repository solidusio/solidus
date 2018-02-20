# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/store_credit_event_factory'

RSpec.describe 'store credit event factory' do
  let(:factory_class) { Spree::StoreCreditEvent }

  describe 'plain store credit event' do
    let(:factory) { :store_credit_event }

    it "builds successfully" do
      expect(build(factory)).to be_a(factory_class)
    end

    # No test for .create, as this base factory misses an `action`
    # and thus violates a NOT NULL constraint on e the DB
  end

  describe 'store credit auth event' do
    let(:factory) { :store_credit_auth_event }

    it_behaves_like 'a working factory'
  end

  describe 'store credit capture event' do
    let(:factory) { :store_credit_capture_event }

    it_behaves_like 'a working factory'
  end

  describe 'store credit adjustment event' do
    let(:factory) { :store_credit_adjustment_event }

    it_behaves_like 'a working factory'
  end

  describe 'store credit invalidate event' do
    let(:factory) { :store_credit_invalidate_event }

    it_behaves_like 'a working factory'
  end
end
