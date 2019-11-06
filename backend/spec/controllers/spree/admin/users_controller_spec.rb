# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::UsersController, type: :controller do
  let(:user) { create(:user) }

  let(:state) { create(:state, state_code: 'NY') }
  let(:valid_address_attributes) do
    {
      firstname: 'Foo',
      lastname: 'Bar',
      city: "New York",
      country_id: state.country.id,
      state_id: state.id,
      phone: '555-555-5555',
      address1: '123 Fake St.',
      zipcode: '10001',
    }
  end

  context "#show" do
    stub_authorization! do |_user|
      can [:admin, :manage], Spree.user_class
    end

    it "redirects to edit" do
      get :show, params: { id: user.id }
      expect(response).to redirect_to spree.edit_admin_user_path(user)
    end
  end

  context '#authorize_admin' do
    context "with ability to admin users" do
      stub_authorization! do |_user|
        can [:manage], Spree.user_class
      end

      it 'can visit index' do
        post :index
        expect(response).to be_successful
      end

      it "allows admins to update a user's API key" do
        expect {
          put :generate_api_key, params: { id: user.id }
        }.to change { user.reload.spree_api_key }
        expect(response).to redirect_to(spree.edit_admin_user_path(user))
      end

      it "allows admins to clear a user's API key" do
        user.generate_spree_api_key!
        expect {
          put :clear_api_key, params: { id: user.id }
        }.to change{ user.reload.spree_api_key }.to(nil)
        expect(response).to redirect_to(spree.edit_admin_user_path(user))
      end
    end

    context "without ability to admin users" do
      stub_authorization! do |_user|
      end

      it 'denies access' do
        post :index
        expect(response).to redirect_to '/unauthorized'
      end
    end
  end

  describe "#create" do
    let(:dummy_role) { Spree::Role.create(name: "dummyrole") }

    # The created user
    def user
      Spree.user_class.last
    end

    stub_authorization! do |_user|
      can :manage, Spree.user_class
    end

    context "when the user can manage roles" do
      stub_authorization! do |_user|
        can :manage, Spree.user_class
        can :manage, Spree::Role
      end

      it "can create user with roles" do
        post :create, params: { user: { first_name: "Bob", spree_role_ids: [dummy_role.id] } }
        expect(user.spree_roles).to eq([dummy_role])
      end

      it "can create user without roles" do
        post :create, params: { user: { first_name: "Bob" } }
        expect(user.spree_roles).to eq([])
      end
    end

    context "when the user cannot manage roles" do
      it "cannot assign users roles" do
        post :create, params: { user: { first_name: "Bob", spree_role_ids: [dummy_role.id] } }
        expect(user.spree_roles).to eq([])
      end

      it "can create user without roles" do
        post :create, params: { user: { first_name: "Bob" } }
        expect(user.spree_roles).to eq([])
      end
    end

    it "can create a shipping_address" do
      post :create, params: { user: { ship_address_attributes: valid_address_attributes } }
      expect(user.reload.ship_address.city).to eq('New York')
    end

    it "can create a billing_address" do
      post :create, params: { user: { bill_address_attributes: valid_address_attributes } }
      expect(user.reload.bill_address.city).to eq('New York')
    end

    it "can set stock locations" do
      location = Spree::StockLocation.create(name: "my_location")
      location_2 = Spree::StockLocation.create(name: "my_location_2")
      post :create, params: { user: { stock_location_ids: [location.id, location_2.id] } }
      expect(user.stock_locations).to match_array([location, location_2])
    end
  end

  describe "#update" do
    let(:dummy_role) { Spree::Role.create(name: "dummyrole") }
    let(:ability) { Spree::Ability.new(user) }

    stub_authorization! do |_user|
      can :manage, Spree.user_class
    end

    context "when the user can manage roles" do
      stub_authorization! do |_user|
        can :manage, Spree.user_class
        can :manage, Spree::Role
      end

      it "can set roles" do
        expect {
          put :update, params: { id: user.id, user: { first_name: "Bob", spree_role_ids: [dummy_role.id] } }
        }.to change { user.reload.spree_roles.to_a }.to([dummy_role])
      end

      it "can clear roles" do
        user.spree_roles << dummy_role
        expect {
          put :update, params: { id: user.id, user: { first_name: "Bob", spree_role_ids: [""] } }
        }.to change { user.reload.spree_roles.to_a }.to([])
      end

      context 'when no role params are present' do
        it 'does not clear all present user roles' do
          user.spree_roles << dummy_role
          put :update, params: { id: user.id, user: { first_name: "Bob" } }
          expect(user.reload.spree_roles).to_not be_empty
        end
      end
    end

    context "when the user cannot manage roles" do
      it "cannot set roles" do
        expect {
          put :update, params: { id: user.id, user: { first_name: "Bob", spree_role_ids: [dummy_role.id] } }
        }.not_to change { user.reload.spree_roles.to_a }
      end

      it "cannot clear roles" do
        user.spree_roles << dummy_role
        expect {
          put :update, params: { id: user.id, user: { first_name: "Bob" } }
        }.not_to change { user.reload.spree_roles.to_a }
      end
    end

    context "allowed to update email" do
      stub_authorization! do |_user|
        can [:admin, :update, :update_email], Spree.user_class
      end

      it "can change email of a user" do
        expect {
          put :update, params: { id: user.id, user: { email: "bob@example.com" } }
        }.to change { user.reload.email }.to("bob@example.com")
      end
    end

    context "not allowed to update email" do
      stub_authorization! do |_user|
        can [:admin, :update], Spree.user_class
      end

      it "cannot change email of a user" do
        expect {
          put :update, params: { id: user.id, user: { email: "bob@example.com" } }
        }.not_to change { user.reload.email }
      end
    end

    context "allowed to update passwords" do
      it "can change password of a user" do
        expect {
          put :update, params: { id: user.id, user: { password: "diff123", password_confirmation: "diff123" } }
        }.to_not raise_error
      end
    end

    context "not allowed to update passwords" do
      stub_authorization! do |_user|
        can [:admin, :update], Spree.user_class
      end

      it "cannot change password of a user" do
        allow(ActionController::Parameters).
          to receive(:action_on_unpermitted_parameters).and_return(:raise)

        expect {
          put :update, params: { id: user.id, user: { password: "diff123", password_confirmation: "diff123" } }
        }.to raise_error(ActionController::UnpermittedParameters)
      end
    end

    it "can update ship_address attributes" do
      post :update, params: { id: user.id, user: { ship_address_attributes: valid_address_attributes } }
      expect(user.reload.ship_address.city).to eq('New York')
    end

    it "can update bill_address attributes" do
      post :update, params: { id: user.id, user: { bill_address_attributes: valid_address_attributes } }
      expect(user.reload.bill_address.city).to eq('New York')
    end

    it "can set stock locations" do
      location = Spree::StockLocation.create(name: "my_location")
      location_2 = Spree::StockLocation.create(name: "my_location_2")
      post :update, params: { id: user.id, user: { stock_location_ids: [location.id, location_2.id] } }
      expect(user.stock_locations).to match_array([location, location_2])
    end
  end

  describe "#orders" do
    stub_authorization! do |_user|
      can :manage, Spree.user_class
    end

    let(:order) { create(:order) }
    before { user.orders << order }

    it "assigns a list of the users orders" do
      get :orders, params: { id: user.id }
      expect(assigns[:orders].count).to eq 1
      expect(assigns[:orders].first).to eq order
    end

    it "assigns a ransack search for Spree::Order" do
      get :orders, params: { id: user.id }
      expect(assigns[:search]).to be_a Ransack::Search
      expect(assigns[:search].klass).to eq Spree::Order
    end
  end

  describe "#items" do
    stub_authorization! do |_user|
      can :manage, Spree.user_class
    end

    let(:order) { create(:order) }
    before { user.orders << order }

    it "assigns a list of the users orders" do
      get :items, params: { id: user.id }
      expect(assigns[:orders].count).to eq 1
      expect(assigns[:orders].first).to eq order
    end

    it "assigns a ransack search for Spree::Order" do
      get :items, params: { id: user.id }
      expect(assigns[:search]).to be_a Ransack::Search
      expect(assigns[:search].klass).to eq Spree::Order
    end
  end
end
