# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::OrderMutex do
  include ActiveSupport::Testing::TimeHelpers

  let(:order) { create(:order) }

  context "without an existing lock" do
    it "executes the block" do
      expect { |b|
        Spree::OrderMutex.with_lock!(order, &b)
      }.to yield_control.once
    end

    it "releases the lock for subsequent calls" do
      expect { |b|
        Spree::OrderMutex.with_lock!(order, &b)
        Spree::OrderMutex.with_lock!(order, &b)
      }.to yield_control.twice
    end

    it "returns the value of the block" do
      expect(Spree::OrderMutex.with_lock!(order) { 'yay for spree' }).to eq 'yay for spree'
    end
  end

  context "with an existing lock on the same order" do
    it "raises a LockFailed error and then releases the lock" do
      Spree::OrderMutex.with_lock!(order) do
        expect {
          expect { |b|
            Spree::OrderMutex.with_lock!(order, &b)
          }.not_to yield_control
        }.to raise_error(Spree::OrderMutex::LockFailed)
      end

      expect { |b|
        Spree::OrderMutex.with_lock!(order, &b)
      }.to yield_control.once
    end
  end

  context "with an expired existing lock on the same order" do
    around do |example|
      Spree::OrderMutex.with_lock!(order) do
        future = Spree::Config[:order_mutex_max_age].seconds.from_now + 1.second
        travel_to(future) do
          example.run
        end
      end
    end

    it "executes the block" do
      expect { |b|
        Spree::OrderMutex.with_lock!(order, &b)
      }.to yield_control.once
    end
  end

  context "with an existing lock on a different order" do
    let(:order2) { create(:order) }

    around do |example|
      Spree::OrderMutex.with_lock!(order2) { example.run }
    end

    it "executes the block" do
      expect { |b|
        Spree::OrderMutex.with_lock!(order, &b)
      }.to yield_control.once
    end
  end

  context "when an unrelated RecordNotUnique error occurs" do
    def raise_record_not_unique
      raise ActiveRecord::RecordNotUnique.new("Testing")
    end

    it "does not rescue the unrelated error" do
      expect {
        Spree::OrderMutex.with_lock!(order) do
          raise_record_not_unique
        end
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
