require 'spec_helper'

describe Solidus::Order, :type => :model do
  let(:order) { stub_model(Solidus::Order) }

  context "#update!" do
    let(:line_items) { [mock_model(Solidus::LineItem, :amount => 5) ]}

    context "when there are update hooks" do
      before { Solidus::Order.register_update_hook :foo }
      after { Solidus::Order.update_hooks.clear }
      it "should call each of the update hooks" do
        expect(order).to receive :foo
        order.update!
      end
    end
  end
end
