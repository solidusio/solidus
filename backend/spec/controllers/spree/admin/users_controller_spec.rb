require 'spec_helper'
require 'spree/testing_support/bar_ability'

describe Spree::Admin::UsersController, :type => :controller do
  let(:user) { create(:user) }
  let(:mock_user) { mock_model Spree.user_class }

  before do
    allow(controller).to receive_messages :spree_current_user => user
    user.spree_roles.clear
  end

  context "#show" do
    before do
      user.spree_roles << Spree::Role.find_or_create_by(name: 'admin')
    end

    it "redirects to edit" do
      spree_get :show, id: user.id
      expect(response).to redirect_to spree.edit_admin_user_path(user)
    end
  end

  context '#authorize_admin' do
    before { use_mock_user }

    it 'grant access to users with an admin role' do
      user.spree_roles << Spree::Role.find_or_create_by(name: 'admin')
      spree_post :index
      expect(response).to render_template :index
    end

    it "allows admins to update a user's API key" do
      user.spree_roles << Spree::Role.find_or_create_by(name: 'admin')
      expect(mock_user).to receive(:generate_spree_api_key!).and_return(true)
      spree_put :generate_api_key, id: mock_user.id
      expect(response).to redirect_to(spree.edit_admin_user_path(mock_user))
    end

    it "allows admins to clear a user's API key" do
      user.spree_roles << Spree::Role.find_or_create_by(name: 'admin')
      expect(mock_user).to receive(:clear_spree_api_key!).and_return(true)
      spree_put :clear_api_key, id: mock_user.id
      expect(response).to redirect_to(spree.edit_admin_user_path(mock_user))
    end

    it 'deny access to users with an bar role' do
      user.spree_roles << Spree::Role.find_or_create_by(name: 'bar')
      Spree::Ability.register_ability(BarAbility)
      spree_post :index
      expect(response).to redirect_to '/unauthorized'
    end

    it 'deny access to users with an bar role' do
      user.spree_roles << Spree::Role.find_or_create_by(name: 'bar')
      Spree::Ability.register_ability(BarAbility)
      spree_post :update, { id: '9' }
      expect(response).to redirect_to '/unauthorized'
    end

    it 'deny access to users without an admin role' do
      allow(user).to receive_messages :has_spree_role? => false
      spree_post :index
      expect(response).to redirect_to '/unauthorized'
    end
  end

  describe "#create" do
    before do
      use_mock_user
      allow(mock_user).to receive_messages(:spree_roles= => true, :stock_locations= => true)
      user.spree_roles << Spree::Role.find_or_create_by(name: 'admin')
    end

    it "can create a shipping_address" do
      expect(Spree.user_class).to receive(:new).with(hash_including(
        "ship_address_attributes" => { "city" => "New York" }
      ))
      spree_post :create, { :user => { :ship_address_attributes => { :city => "New York" } } }
    end

    it "can create a billing_address" do
      expect(Spree.user_class).to receive(:new).with(hash_including(
        "bill_address_attributes" => { "city" => "New York" }
      ))
      spree_post :create, { :user => { :bill_address_attributes => { :city => "New York" } } }
    end

    it "can set roles" do
      role = Spree::Role.create(name: "my_role")
      role_2 = Spree::Role.create(name: "my_role_2")
      expect(mock_user).to receive(:spree_roles=).with([role, role_2])
      spree_post :create, { user: { spree_role_ids: [role.id, role_2.id] } }
    end

    it "can set stock locations" do
      location = Spree::StockLocation.create(name: "my_location")
      location_2 = Spree::StockLocation.create(name: "my_location_2")
      expect(mock_user).to receive(:stock_locations=).with([location, location_2])
      spree_post :create, { user: { stock_location_ids: [location.id, location_2.id] } }
    end
  end

  describe "#update" do
    before do
      use_mock_user
      allow(mock_user).to receive_messages(:spree_roles= => true, :stock_locations= => true)
      user.spree_roles << Spree::Role.find_or_create_by(name: 'admin')
    end

    it "allows shipping address attributes through" do
      expect(mock_user).to receive(:update_attributes).with(hash_including(
        "ship_address_attributes" => { "city" => "New York" }
      ))
      spree_put :update, { :id => mock_user.id, :user => { :ship_address_attributes => { :city => "New York" } } }
    end

    it "allows billing address attributes through" do
      expect(mock_user).to receive(:update_attributes).with(hash_including(
        "bill_address_attributes" => { "city" => "New York" }
      ))
      spree_put :update, { :id => mock_user.id, :user => { :bill_address_attributes => { :city => "New York" } } }
    end

    it "can set roles" do
      role = Spree::Role.create(name: "my_role")
      role_2 = Spree::Role.create(name: "my_role_2")
      expect(mock_user).to receive(:spree_roles=).with([role, role_2])
      spree_put :update, { id: mock_user.id, user: { spree_role_ids: [role.id, role_2.id] } }
    end

    it "can set stock locations" do
      location = Spree::StockLocation.create(name: "my_location")
      location_2 = Spree::StockLocation.create(name: "my_location_2")
      expect(mock_user).to receive(:stock_locations=).with([location, location_2])
      spree_put :update, { id: mock_user.id, user: { stock_location_ids: [location.id, location_2.id] } }
    end
  end

  describe "#orders" do
    let(:order) { create(:order) }
    before do
      user.orders << order
      user.spree_roles << Spree::Role.find_or_create_by(name: 'admin')
    end

    it "assigns a list of the users orders" do
      spree_get :orders, { :id => user.id }
      expect(assigns[:orders].count).to eq 1
      expect(assigns[:orders].first).to eq order
    end

    it "assigns a ransack search for Spree::Order" do
      spree_get :orders, { :id => user.id }
      expect(assigns[:search]).to be_a Ransack::Search
      expect(assigns[:search].klass).to eq Spree::Order
    end
  end

  describe "#items" do
    let(:order) { create(:order) }
    before do
      user.orders << order
      user.spree_roles << Spree::Role.find_or_create_by(name: 'admin')
    end

    it "assigns a list of the users orders" do
      spree_get :items, { :id => user.id }
      expect(assigns[:orders].count).to eq 1
      expect(assigns[:orders].first).to eq order
    end

    it "assigns a ransack search for Spree::Order" do
      spree_get :items, { :id => user.id }
      expect(assigns[:search]).to be_a Ransack::Search
      expect(assigns[:search].klass).to eq Spree::Order
    end
  end
end

def use_mock_user
  mock_user.stub(:save).and_return(true)
  mock_user.stub(:update_attributes).and_return(true)
  Spree.user_class.stub(:find).with(mock_user.id.to_s).and_return(mock_user)
  Spree.user_class.stub(:new).and_return(mock_user)
end
