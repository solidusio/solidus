# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Order, type: :model do
  let(:order) { Spree::Order.new }

  context 'validation' do
    address_scenarios = {
      'use_billing' => { source: :bill_address, target: :ship_address },
      'use_shipping' => { source: :ship_address, target: :bill_address }
    }

    address_scenarios.each do |use_attribute, addresses|
      context "when #{use_attribute} is populated" do
        before do
          order.send("#{addresses[:source]}=", stub_model(Spree::Address))
          order.send("#{addresses[:target]}=", nil)
        end

        ['true', true, '1'].each do |truthy_value|
          context "with #{truthy_value.inspect}" do
            before { order.send("#{use_attribute}=", truthy_value) }

            it "clones the #{addresses[:source]} to the #{addresses[:target]}" do
              order.valid?
              expect(order.send(addresses[:target])).to eq(order.send(addresses[:source]))
            end
          end
        end

        context "with something other than a 'truthful' value" do
          before { order.send("#{use_attribute}=", '0') }

          it "does not clone the #{addresses[:source]} to the #{addresses[:target]}" do
            order.valid?
            expect(order.send(addresses[:target])).to be_nil
          end
        end
      end
    end
  end
end
