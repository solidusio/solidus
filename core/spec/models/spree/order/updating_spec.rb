# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Order, type: :model do
  let(:order) { create(:order) }

  context "#update!" do
    context "when there are update hooks", partial_double_verification: false do
      before { Spree::Order.register_update_hook :foo }
      after { Spree::Order.update_hooks.clear }
      it "should call each of the update hooks" do
        expect(order).to receive :foo
        order.recalculate
      end
    end
  end
end
