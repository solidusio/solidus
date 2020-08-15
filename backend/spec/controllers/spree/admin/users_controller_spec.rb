# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::UsersController, type: :controller do
  let(:user) { create(:user) }

  let(:state) { create(:state, state_code: 'NY') }
  let(:valid_address_attributes) do
    {
      name: 'Foo Bar',
      city: "New York",
      country_id: state.country.id,
      state_id: state.id,
      phone: '555-555-5555',
      address1: '123 Fake St.',
      zipcode: '10001',
    }
  end

  context "#index" do
    stub_authorization! do |_user|
      can :manage, Spree.user_class
    end

    context "when the user can manage all users" do
      it "assigns a list of all users as @collection" do
        get :index, params: { id: user.id }
        expect(assigns(:collection)).to eq [user]
      end

      it "assigns a ransack search for Spree.user_class" do
        get :index, params: { id: user.id }
        expect(assigns[:search]).to be_a Ransack::Search
        expect(assigns[:search].klass).to eq Spree.user_class
      end
    end

    context "when user cannot manage some users" do
      stub_authorization! do |_user|
        can :manage, Spree.user_class
        cannot :manage, Spree.user_class, email: 'not_accessible_user@example.com'
      end

      it "assigns a list of accessible users as @collection" do
        create(:user, email: 'not_accessible_user@example.com')

        get :index, params: { id: user.id }
        expect(assigns(:collection)).to eq [user]
      end
    end

    context "when Spree.user_class does not respond to #accessible_by" do
      it "assigns a list of all users as @collection" do
        allow(Spree.user_class).to receive(:respond_to?).and_call_original
        allow(Spree.user_class).to receive(:respond_to?).with(:accessible_by).and_return(false)

        get :index, params: { id: user.id }
        expect(assigns(:collection)).to eq [user]
      end
    end
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
        expect(Spree::Deprecation).to receive(:warn)
        expect {
          put :generate_api_key, params: { id: user.id }
        }.to change { user.reload.spree_api_key }
        expect(response).to redirect_to(spree.edit_admin_user_path(user))
      end

      it "allows admins to clear a user's API key" do
        expect(Spree::Deprecation).to receive(:warn)
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

  context '#new' do
    context "when the user can manage all roles" do
      stub_authorization! do |_user|
        can :manage, Spree.user_class
        can :index, Spree::Role
      end

      it "assigns a list of all roles as @roles" do
        role = create(:role)

        get :new, params: { id: user.id }
        expect(assigns(:roles)).to eq [role]
      end
    end

    context "when user cannot list some roles" do
      stub_authorization! do |_user|
        can :manage, Spree.user_class
        can :index, Spree::Role
        cannot :index, Spree::Role, name: 'not_accessible_role'
      end

      it "assigns a list of accessible roles as @roles" do
        accessible_role = create(:role, name: 'accessible_role')
        create(:role, name: 'not_accessible_role')

        get :new, params: { id: user.id }
        expect(assigns(:roles)).to eq [accessible_role]
      end
    end

    context "when the user can manage all stock_locations" do
      stub_authorization! do |_user|
        can :manage, Spree.user_class
        can :index, Spree::StockLocation
      end

      it "assigns a list of all stock_locations as @stock_locations" do
        stock_location = create(:stock_location)

        get :new, params: { id: user.id }
        expect(assigns(:stock_locations)).to eq [stock_location]
      end
    end

    context "when user cannot list some stock_locations" do
      stub_authorization! do |_user|
        can :manage, Spree.user_class
        can :index, Spree::StockLocation
        cannot :index, Spree::StockLocation, name: 'not_accessible_stock_location'
      end

      it "assigns a list of accessible stock_locations as @stock_locations" do
        accessible_stock_location = create(:stock_location, name: 'accessible_stock_location')
        create(:stock_location, name: 'not_accessible_stock_location')

        get :new, params: { id: user.id }
        expect(assigns(:stock_locations)).to eq [accessible_stock_location]
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
        post :create, params: { user: { name: "Bob Bloggs", spree_role_ids: [dummy_role.id] } }
        expect(user.spree_roles).to eq([dummy_role])
      end

      it "can create user without roles" do
        post :create, params: { user: { name: "Bob Bloggs" } }
        expect(user.spree_roles).to eq([])
      end
    end

    context "when the user cannot manage roles" do
      stub_authorization! do |_user|
        can :manage, Spree.user_class
        cannot :manage, Spree::Role
      end

      it "cannot assign users roles" do
        post :create, params: { user: { name: "Bob Bloggs", spree_role_ids: [dummy_role.id] } }
        expect(user.spree_roles).to eq([])
      end

      it "can create user without roles" do
        post :create, params: { user: { name: "Bob Bloggs" } }
        expect(user.spree_roles).to eq([])
      end
    end

    context "when the user can manage only some roles" do
      stub_authorization! do |_user|
        can :manage, Spree.user_class
        can :manage, Spree::Role
        cannot :manage, Spree::Role, name: "not_accessible_role"
      end

      it "can assign accessible roles to user" do
        role1 = Spree::Role.create(name: "accessible_role")
        role2 = Spree::Role.create(name: "not_accessible_role")
        post :create, params: { user: { spree_role_ids: [role1.id, role2.id] } }
        expect(user.spree_roles).to eq([role1])
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

    context "when the user can manage stock locations" do
      stub_authorization! do |_user|
        can :manage, Spree.user_class
        can :manage, Spree::StockLocation
      end

      it "can create user with stock locations" do
        location = Spree::StockLocation.create(name: "my_location")
        post :create, params: { user: { stock_location_ids: [location.id] } }
        expect(user.stock_locations).to eq([location])
      end
    end

    context "when the user cannot manage stock locations" do
      stub_authorization! do |_user|
        can :manage, Spree.user_class
        cannot :manage, Spree::StockLocation
      end

      it "cannot assign users stock locations" do
        location = Spree::StockLocation.create(name: "my_location")
        post :create, params: { user: { stock_location_ids: [location.id] } }
        expect(user.stock_locations).to eq([])
      end
    end

    context "when the user can manage only some stock locations" do
      stub_authorization! do |_user|
        can :manage, Spree.user_class
        can :manage, Spree::StockLocation
        cannot :manage, Spree::StockLocation, name: "not_accessible_location"
      end

      it "can assign accessible stock locations to user" do
        location1 = Spree::StockLocation.create(name: "accessible_location")
        location2 = Spree::StockLocation.create(name: "not_accessible_location")
        post :create, params: { user: { stock_location_ids: [location1.id, location2.id] } }
        expect(user.stock_locations).to eq([location1])
      end
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
          put :update, params: { id: user.id, user: { name: "Bob Bloggs", spree_role_ids: [dummy_role.id] } }
        }.to change { user.reload.spree_roles.to_a }.to([dummy_role])
      end

      it "can clear roles" do
        user.spree_roles << dummy_role
        expect {
          put :update, params: { id: user.id, user: { name: "Bob Bloggs", spree_role_ids: [""] } }
        }.to change { user.reload.spree_roles.to_a }.to([])
      end

      context 'when no role params are present' do
        it 'does not clear all present user roles' do
          user.spree_roles << dummy_role
          put :update, params: { id: user.id, user: { name: "Bob Bloggs" } }
          expect(user.reload.spree_roles).to_not be_empty
        end
      end
    end

    context "when the user cannot manage roles" do
      it "cannot set roles" do
        expect {
          put :update, params: { id: user.id, user: { name: "Bob Bloggs", spree_role_ids: [dummy_role.id] } }
        }.not_to change { user.reload.spree_roles.to_a }
      end

      it "cannot clear roles" do
        user.spree_roles << dummy_role
        expect {
          put :update, params: { id: user.id, user: { name: "Bob Bloggs" } }
        }.not_to change { user.reload.spree_roles.to_a }
      end
    end

    context "when the user can manage only some stock locations" do
      stub_authorization! do |_user|
        can :manage, Spree.user_class
        can :manage, Spree::Role
        cannot :manage, Spree::Role, name: "not_accessible_role"
      end

      it "can update accessible roles to user" do
        role1 = Spree::Role.create(name: "accessible_role")
        role2 = Spree::Role.create(name: "not_accessible_role")
        put :update, params: { id: user.id, user: { spree_role_ids: [role1.id, role2.id] } }
        expect(user.reload.spree_roles).to eq([role1])
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

    context "when the user can manage stock locations" do
      stub_authorization! do |_user|
        can :manage, Spree.user_class
        can :manage, Spree::StockLocation
      end

      it "can update user stock locations" do
        location1 = Spree::StockLocation.create(name: "my_location")
        location2 = Spree::StockLocation.create(name: "my_location2")
        user.stock_locations = [location1]
        put :update, params: { id: user.id, user: { stock_location_ids: [location2.id] } }
        expect(user.reload.stock_locations).to eq([location2])
      end
    end

    context "when the user cannot manage stock locations" do
      stub_authorization! do |_user|
        can :manage, Spree.user_class
        cannot :manage, Spree::StockLocation
      end

      it "cannot update users stock locations" do
        location1 = Spree::StockLocation.create(name: "my_location")
        location2 = Spree::StockLocation.create(name: "my_location2")
        user.stock_locations = [location1]
        put :update, params: { id: user.id, user: { stock_location_ids: [location2.id] } }
        expect(user.reload.stock_locations).to eq([location1])
      end
    end

    context "when the user can manage only some stock locations" do
      stub_authorization! do |_user|
        can :manage, Spree.user_class
        can :manage, Spree::StockLocation
        cannot :manage, Spree::StockLocation, name: "not_accessible_location"
      end

      it "can update accessible stock locations to user" do
        location1 = Spree::StockLocation.create(name: "accessible_location")
        location2 = Spree::StockLocation.create(name: "not_accessible_location")
        put :update, params: { id: user.id, user: { stock_location_ids: [location1.id, location2.id] } }
        expect(user.reload.stock_locations).to eq([location1])
      end
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
