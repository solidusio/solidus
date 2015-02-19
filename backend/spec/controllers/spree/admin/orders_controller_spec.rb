require 'spec_helper'
require 'cancan'
require 'spree/testing_support/bar_ability'

# Ability to test access to specific model instances
class OrderSpecificAbility
  include CanCan::Ability

  def initialize(user)
    can [:admin, :manage], Spree::Order, :number => 'R987654321'
  end
end

describe Spree::Admin::OrdersController do

  context "with authorization" do
    stub_authorization!

    before do
      request.env["HTTP_REFERER"] = "http://localhost:3000"

      # ensure no respond_overrides are in effect
      if Spree::BaseController.spree_responders[:OrdersController].present?
        Spree::BaseController.spree_responders[:OrdersController].clear
      end
    end

    let(:order) { mock_model(Spree::Order, :completed? => true, :total => 100, :number => 'R123456789', billing_address: mock_model(Spree::Address)) }
    before do
      Spree::Order.stub :find_by_number! => order
      order.stub(contents: Spree::OrderContents.new(order))
    end

    context "#approve" do
      it "approves an order" do
        expect(order.contents).to receive(:approve).with(user: controller.try_spree_current_user)
        spree_put :approve, id: order.number
        expect(flash[:success]).to eq Spree.t(:order_approved)
      end
    end

    context "#cancel" do
      let(:order) { create(:order, state: 'complete', completed_at: Time.now) }
      it "cancels an order" do
        expect do
          spree_put :cancel, id: order.number
        end.to change { order.reload.state }.from('complete').to('canceled')
        expect(flash[:success]).to eq Spree.t(:order_canceled)
      end
    end

    context "#resume" do
      it "resumes an order" do
        expect(order).to receive(:resume!)
        spree_put :resume, id: order.number
        expect(flash[:success]).to eq Spree.t(:order_resumed)
      end
    end

    context "pagination" do
      it "can page through the orders" do
        spree_get :index, :page => 2, :per_page => 10
        assigns[:orders].offset_value.should == 10
        assigns[:orders].limit_value.should == 10
      end
    end

    # Test for #3346
    context "#new" do
      it "imports a new order and sets the current user as a creator" do
        Spree::Core::Importer::Order.should_receive(:import)
          .with(nil, {'created_by_id' => controller.try_spree_current_user.id})
          .and_return(order)
        spree_get :new
      end

      context "when a user_id is passed as a parameter" do
        let(:user)  { mock_model(Spree.user_class) }
        before { Spree.user_class.stub :find_by_id => user }

        it "imports a new order and assigns the user to the order" do
          Spree::Core::Importer::Order.should_receive(:import)
            .with(user, {'created_by_id' => controller.try_spree_current_user.id})
            .and_return(order)
          spree_get :new, { user_id: user.id }
        end
      end
    end

    # Regression test for #3684
    context "#edit" do
      it "does not refresh rates if the order is complete" do
        order.stub :completed? => true
        order.should_not_receive :refresh_shipment_rates
        spree_get :edit, :id => order.number
      end

      it "does refresh the rates if the order is incomplete" do
        order.stub :completed? => false
        order.should_receive :refresh_shipment_rates
        spree_get :edit, :id => order.number
      end
    end

    describe '#advance' do
      subject do
        spree_put :advance, id: order.number
      end

      context 'when incomplete' do
        before do
          order.stub(:completed?).and_return(false, true)
          order.stub(:next).and_return(true, false)
        end

        context 'when successful' do
          before { order.stub(:confirm?).and_return(true) }

          it 'messages and redirects' do
            subject
            expect(flash[:success]).to eq Spree.t('order_ready_for_confirm')
            expect(response).to redirect_to(spree.confirm_admin_order_path(order))
          end
        end

        context 'when unsuccessful' do
          before do
            order.stub(:confirm?).and_return(false)
            order.stub(:errors).and_return(double(full_messages: ['failed']))
          end

          it 'messages and redirects' do
            subject
            expect(flash[:error]) == order.errors.full_messages
            expect(response).to redirect_to(spree.confirm_admin_order_path(order))
          end
        end
      end

      context 'when already completed' do
        before { order.stub :completed? => true }

        it 'messages and redirects' do
          subject
          expect(flash[:notice]).to eq Spree.t('order_already_completed')
          expect(response).to redirect_to(spree.edit_admin_order_path(order))
        end
      end
    end

    describe '#confirm' do
      subject do
        spree_get :confirm, id: order.number
      end

      context 'when incomplete' do
        before { order.stub(completed?: false, confirm?: false) }

        it 'is successful' do
          subject
          expect(response.status).to eq 200
        end
      end

      context 'when already completed' do
        before { order.stub :completed? => true }

        it 'redirects to edit' do
          subject
          expect(response).to redirect_to(spree.edit_admin_order_path(order))
        end
      end
    end

    describe "#complete" do
      subject do
        spree_put :complete, id: order.number
      end

      context 'when successful' do
        before { order.stub(:complete!) }

        it 'completes the order' do
          expect(order).to receive(:complete!)
          subject
        end

        it 'messages and redirects' do
          subject
          expect(flash[:success]).to eq Spree.t(:order_completed)
          expect(response).to redirect_to(spree.edit_admin_order_path(order))
        end
      end

      context 'with an StateMachine::InvalidTransition error' do
        let(:order) { create(:order) }

        it 'messages and redirects' do
          subject
          expect(response).to redirect_to(spree.confirm_admin_order_path(order))
          expect(flash[:error].to_s).to include("Cannot transition state via :complete from :cart")
        end
      end

      context 'insufficient stock to complete the order' do
        before do
          order.should_receive(:complete!).and_raise Spree::LineItem::InsufficientStock
        end

        it 'messages and redirects' do
          subject
          expect(response).to redirect_to(spree.cart_admin_order_path(order))
          expect(flash[:error].to_s).to eq Spree.t(:insufficient_stock_for_order)
        end
      end
    end

    # Test for #3919
    context "search" do
      let(:user) { create(:user) }

      before do
        controller.stub :spree_current_user => user
        user.spree_roles << Spree::Role.find_or_create_by(name: 'admin')

        create(:completed_order_with_totals)
        expect(Spree::Order.count).to eq 1
      end

      it "does not display duplicated results" do
        spree_get :index, q: {
          line_items_variant_id_in: Spree::Order.first.variants.map(&:id)
        }
        expect(assigns[:orders].map { |o| o.number }.count).to eq 1
      end
    end
  end

  context '#authorize_admin' do
    let(:user) { create(:user) }
    let(:order) { create(:completed_order_with_totals, :number => 'R987654321') }

    before do
      Spree::Order.stub :find_by_number! => order
      controller.stub :spree_current_user => user
    end

    it 'should grant access to users with an admin role' do
      user.spree_roles << Spree::Role.find_or_create_by(name: 'admin')
      spree_post :index
      response.should render_template :index
    end

    it 'should grant access to users with an bar role' do
      user.spree_roles << Spree::Role.find_or_create_by(name: 'bar')
      Spree::Ability.register_ability(BarAbility)
      spree_post :index
      response.should render_template :index
      Spree::Ability.remove_ability(BarAbility)
    end

    it 'should deny access to users with an bar role' do
      order.stub(:update_attributes).and_return true
      order.stub(:user).and_return Spree.user_class.new
      order.stub(:token).and_return nil
      user.spree_roles.clear
      user.spree_roles << Spree::Role.find_or_create_by(name: 'bar')
      Spree::Ability.register_ability(BarAbility)
      spree_put :update, { :id => 'R123' }
      response.should redirect_to('/unauthorized')
      Spree::Ability.remove_ability(BarAbility)
    end

    it 'should deny access to users without an admin role' do
      user.stub :has_spree_role? => false
      spree_post :index
      response.should redirect_to('/unauthorized')
    end

    it 'should restrict returned order(s) on index when using OrderSpecificAbility' do
      number = order.number

      3.times { create(:completed_order_with_totals) }
      Spree::Order.complete.count.should eq 4
      Spree::Ability.register_ability(OrderSpecificAbility)

      user.stub :has_spree_role? => false
      spree_get :index
      response.should render_template :index
      assigns['orders'].size.should eq 1
      assigns['orders'].first.number.should eq number
      Spree::Order.accessible_by(Spree::Ability.new(user), :index).pluck(:number).should eq  [number]
    end
  end

  context "order number not given" do
    stub_authorization!

    it "raise active record not found" do
      expect {
        spree_get :edit, id: nil
      }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "#update" do
    let(:order) { create(:order) }
    let(:payload) do
      {
        id: order.number,
        order: { email: "foo@bar.com" }
      }
    end

    before do
      allow(order.contents).to receive(:update_cart)
      expect(Spree::Order).to receive(:find_by_number!) { order }
    end
    subject { spree_put :update, payload }

    it "attempts to update the order" do
      expect(order.contents).to receive(:update_cart).with(payload[:order])
      subject
    end

    context "the order is already completed" do
      before { allow(order).to receive(:completed?) { true } }

      it "renders the edit route" do
        subject
        expect(response).to render_template(:edit)
      end
    end

    context "the order is not completed" do
      before { allow(order).to receive(:completed?) { false } }

      it "redirects to the customer path" do
        subject
        expect(response).to redirect_to(spree.admin_order_customer_path(order))
      end
    end

    context "the order has no line items" do
      let(:order) { Spree::Order.new }
      it "includes an error on the order" do
        subject
        expect(order.errors[:line_items]).to include Spree.t('errors.messages.blank')
      end
    end

  end
end
