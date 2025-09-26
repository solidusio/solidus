# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API Orders", type: :request do
  let!(:order) { create(:order) }
  let(:variant) { create(:variant) }
  let(:line_item) { create(:line_item) }
  let(:address_params) { {country_id: Country.first.id, state_id: State.first.id} }

  let(:current_api_user) do
    user = Spree.user_class.new(email: "solidus@example.com")
    user.generate_spree_api_key!
    user
  end

  before do
    stub_authentication!
  end

  describe "POST create" do
    let(:target_user) { create :user }
    let(:attributes) { {user_id: target_user.id, email: target_user.email} }

    subject do
      post spree.api_orders_path, params: {order: attributes}
      response
    end

    context "when the current user cannot administrate the order" do
      custom_authorization! do |_|
        can :create, Spree::Order
      end

      context "with existing promotion" do
        let(:discount) { 2 }
        before do
          create(:promotion, :with_line_item_adjustment, apply_automatically: true, adjustment_rate: discount)
        end

        it "activates the promotion" do
          post spree.api_orders_path, params: {order: {line_items: {"0" => {variant_id: variant.to_param, quantity: 1}}}}
          order = Spree::Order.last
          line_item = order.line_items.first
          expect(order.total).to eq(line_item.price - discount)
        end
      end
    end
  end
end
