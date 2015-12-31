require 'spec_helper'
require 'solidus/testing_support/bar_ability'

describe Solidus::Admin::UsersController, :type => :controller do
  let(:user) { create(:user) }
  let(:mock_user) { mock_model Solidus.user_class }

  before do
    allow(controller).to receive_messages :solidus_current_user => user
    user.solidus_roles.clear
  end

  context "#show" do
    before do
      user.solidus_roles << Solidus::Role.find_or_create_by(name: 'admin')
    end

    it "redirects to edit" do
      solidus_get :show, id: user.id
      expect(response).to redirect_to solidus.edit_admin_user_path(user)
    end
  end

  context '#authorize_admin' do
    before { use_mock_user }

    it 'grant access to users with an admin role' do
      user.solidus_roles << Solidus::Role.find_or_create_by(name: 'admin')
      solidus_post :index
      expect(response).to render_template :index
    end

    it "allows admins to update a user's API key" do
      user.solidus_roles << Solidus::Role.find_or_create_by(name: 'admin')
      expect(mock_user).to receive(:generate_solidus_api_key!).and_return(true)
      solidus_put :generate_api_key, id: mock_user.id
      expect(response).to redirect_to(solidus.edit_admin_user_path(mock_user))
    end

    it "allows admins to clear a user's API key" do
      user.solidus_roles << Solidus::Role.find_or_create_by(name: 'admin')
      expect(mock_user).to receive(:clear_solidus_api_key!).and_return(true)
      solidus_put :clear_api_key, id: mock_user.id
      expect(response).to redirect_to(solidus.edit_admin_user_path(mock_user))
    end

    it 'deny access to users with an bar role' do
      user.solidus_roles << Solidus::Role.find_or_create_by(name: 'bar')
      Solidus::Ability.register_ability(BarAbility)
      solidus_post :index
      expect(response).to redirect_to '/unauthorized'
    end

    it 'deny access to users with an bar role' do
      user.solidus_roles << Solidus::Role.find_or_create_by(name: 'bar')
      Solidus::Ability.register_ability(BarAbility)
      solidus_post :update, { id: '9' }
      expect(response).to redirect_to '/unauthorized'
    end

    it 'deny access to users without an admin role' do
      allow(user).to receive_messages :has_solidus_role? => false
      solidus_post :index
      expect(response).to redirect_to '/unauthorized'
    end
  end

  describe "#create" do
    let(:dummy_role) { Solidus::Role.create(name: "dummyrole") }

    before do
      use_mock_user
      allow(mock_user).to receive_messages(:solidus_roles= => true, :stock_locations= => true)
      user.solidus_roles << Solidus::Role.find_or_create_by(name: 'admin')
    end

    context "when the user can manage roles" do
      it "can set roles" do
        expect(mock_user).to receive(:solidus_roles=).with([dummy_role])
        solidus_post :create, { id: mock_user.id, user: { first_name: "Bob", solidus_role_ids: [dummy_role.id] } }
      end

      it "can clear roles" do
        expect(mock_user).to receive(:solidus_roles=).with([])
        solidus_post :create, { id: mock_user.id, user: { first_name: "Bob"}  }
      end
    end

    context "when the user cannot manage roles" do
      before do
        user.solidus_roles = [Solidus::Role.find_or_create_by(name: "user_management")]
      end

      it "cannot set roles" do
        expect(mock_user).to_not receive(:solidus_roles=)
        solidus_post :create, { user: { solidus_role_ids: [dummy_role.id] } }
      end

      it "cannot set roles" do
        expect(mock_user).to_not receive(:solidus_roles=)
        solidus_post :create, { id: mock_user.id, user: { first_name: "Bob", solidus_role_ids: [dummy_role.id] } }
      end

      it "cannot clear roles" do
        expect(mock_user).to_not receive(:solidus_roles=)
        solidus_post :create, { id: mock_user.id, user: { first_name: "Bob"}  }
      end
    end

    it "can create a shipping_address" do
      expect(Solidus.user_class).to receive(:new).with(hash_including(
        "ship_address_attributes" => { "city" => "New York" }
      ))
      solidus_post :create, { :user => { :ship_address_attributes => { :city => "New York" } } }
    end

    it "can create a billing_address" do
      expect(Solidus.user_class).to receive(:new).with(hash_including(
        "bill_address_attributes" => { "city" => "New York" }
      ))
      solidus_post :create, { :user => { :bill_address_attributes => { :city => "New York" } } }
    end

    it "can set stock locations" do
      location = Solidus::StockLocation.create(name: "my_location")
      location_2 = Solidus::StockLocation.create(name: "my_location_2")
      expect(mock_user).to receive(:stock_locations=).with([location, location_2])
      solidus_post :create, { user: { stock_location_ids: [location.id, location_2.id] } }
    end
  end

  describe "#update" do
    let(:dummy_role) { Solidus::Role.create(name: "dummyrole") }
    let(:ability) { Solidus::Ability.new(user) }
    before do
      use_mock_user
      allow(mock_user).to receive_messages(:solidus_roles= => true, :stock_locations= => true)
      allow(controller).to receive(:current_ability) { ability }
      Solidus::PermissionSets::UserManagement.new(ability).activate!
    end

    context "as a superuser" do
      before { Solidus::PermissionSets::SuperUser.new(ability).activate! }

      it "can set roles" do
        expect(mock_user).to receive(:solidus_roles=).with([dummy_role])
        solidus_put :update, { id: mock_user.id, user: { first_name: "Bob", solidus_role_ids: [dummy_role.id] } }
      end

      it "can clear roles" do
        expect(mock_user).to receive(:solidus_roles=).with([])
        solidus_put :update, { id: mock_user.id, user: { first_name: "Bob" }  }
      end

      it "can change email of a user with no roles" do
        expect(mock_user).to receive(:update_attributes).with({ email: "bob@example.com" })
        solidus_put :update, { id: mock_user.id, user: { email: "bob@example.com" } }
      end

      it "can change email of a user with roles" do
        allow(mock_user).to receive(:solidus_roles) { [dummy_role] }
        expect(mock_user).to receive(:update_attributes).with({ email: "bob@example.com" })
        solidus_put :update, { id: mock_user.id, user: { email: "bob@example.com" } }
      end
    end

    it "cannot set roles" do
      expect(mock_user).to_not receive(:solidus_roles=)
      solidus_put :update, { id: mock_user.id, user: { first_name: "Bob", solidus_role_ids: [dummy_role.id] } }
    end

    it "cannot clear roles" do
      expect(mock_user).to_not receive(:solidus_roles=)
      solidus_put :update, { id: mock_user.id, user: { first_name: "Bob" }  }
    end

    it "can change email of a user with no roles" do
      expect(mock_user).to receive(:update_attributes).with({ email: "bob@example.com" })
      solidus_put :update, { id: mock_user.id, user: { email: "bob@example.com" } }
    end

    it "cannot change email of a user with roles" do
      allow(mock_user).to receive(:solidus_roles) { [dummy_role] }
      expect(mock_user).to receive(:update_attributes).with({})
      solidus_put :update, { id: mock_user.id, user: { email: "bob@example.com" } }
    end

    it "allows shipping address attributes through" do
      expect(mock_user).to receive(:update_attributes).with(hash_including(
        "ship_address_attributes" => { "city" => "New York" }
      ))
      solidus_put :update, { :id => mock_user.id, :user => { :ship_address_attributes => { :city => "New York" } } }
    end

    it "allows billing address attributes through" do
      expect(mock_user).to receive(:update_attributes).with(hash_including(
        "bill_address_attributes" => { "city" => "New York" }
      ))
      solidus_put :update, { :id => mock_user.id, :user => { :bill_address_attributes => { :city => "New York" } } }
    end

    it "can set stock locations" do
      location = Solidus::StockLocation.create(name: "my_location")
      location_2 = Solidus::StockLocation.create(name: "my_location_2")
      expect(mock_user).to receive(:stock_locations=).with([location, location_2])
      solidus_put :update, { id: mock_user.id, user: { stock_location_ids: [location.id, location_2.id] } }
    end
  end

  describe "#orders" do
    let(:order) { create(:order) }
    before do
      user.orders << order
      user.solidus_roles << Solidus::Role.find_or_create_by(name: 'admin')
    end

    it "assigns a list of the users orders" do
      solidus_get :orders, { :id => user.id }
      expect(assigns[:orders].count).to eq 1
      expect(assigns[:orders].first).to eq order
    end

    it "assigns a ransack search for Solidus::Order" do
      solidus_get :orders, { :id => user.id }
      expect(assigns[:search]).to be_a Ransack::Search
      expect(assigns[:search].klass).to eq Solidus::Order
    end
  end

  describe "#items" do
    let(:order) { create(:order) }
    before do
      user.orders << order
      user.solidus_roles << Solidus::Role.find_or_create_by(name: 'admin')
    end

    it "assigns a list of the users orders" do
      solidus_get :items, { :id => user.id }
      expect(assigns[:orders].count).to eq 1
      expect(assigns[:orders].first).to eq order
    end

    it "assigns a ransack search for Solidus::Order" do
      solidus_get :items, { :id => user.id }
      expect(assigns[:search]).to be_a Ransack::Search
      expect(assigns[:search].klass).to eq Solidus::Order
    end
  end
end

def use_mock_user
  allow(mock_user).to receive(:save).and_return(true)
  allow(mock_user).to receive(:update_attributes).and_return(true)
  allow(mock_user).to receive(:solidus_roles).and_return([])
  allow(Solidus.user_class).to receive(:find).with(mock_user.id.to_s).and_return(mock_user)
  allow(Solidus.user_class).to receive(:new).and_return(mock_user)
end
