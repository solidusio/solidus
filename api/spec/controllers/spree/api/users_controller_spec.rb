require 'spec_helper'

module Spree
  describe Api::UsersController, :type => :controller do
    render_views

    let(:user) { create(:user, spree_api_key: SecureRandom.hex) }
    let(:stranger) { create(:user, :email => 'stranger@example.com') }
    let(:attributes) { [:id, :email, :created_at, :updated_at] }

    context "as a normal user" do
      describe "#show" do
        it "can get own details" do
          api_get :show, id: user.id, token: user.spree_api_key
          expect(json_response['email']).to eq user.email
        end

        it "cannot get other users details" do
          api_get :show, id: stranger.id, token: user.spree_api_key

          assert_not_found!
        end

        context "with ability to display users" do
          before do
            user.spree_roles.create!(name: "user_display")
            Spree::RoleConfiguration.configure do |config|
              config.assign_permissions :user_display, [Spree::PermissionSets::UserDisplay]
            end
          end

          it "can get others' details" do
            api_get :show, id: stranger.id, token: user.spree_api_key
            expect(json_response['email']).to eq stranger.email
          end
        end
      end

      describe "#new" do
        it "can learn how to create a new user" do
          api_get :new, token: user.spree_api_key
          expect(json_response["attributes"]).to eq(attributes.map(&:to_s))
        end
      end

      describe "#create" do
        it "can create a new user" do
          user_params = { email: 'new@example.com', password: 'spree123', password_confirmation: 'spree123' }

          api_post :create, :user => user_params, token: user.spree_api_key
          expect(response.status).to eq(201)
          expect(json_response['email']).to eq 'new@example.com'
          expect(json_response).not_to have_key('password')
        end

        it "can set address attributes" do
          user_params = {
            email: 'new@example.com',
            password: 'spree123',
            password_confirmation: 'spree123',
            bill_address_attributes: build(:address, city: "New York").attributes,
            ship_address_attributes: build(:address, city: "Chicago").attributes,
          }
          api_post :create, :user => user_params, token: user.spree_api_key
          expect(response.status).to eq(201)
          expect(json_response['bill_address']['city']).to eq 'New York'
          expect(json_response['ship_address']['city']).to eq 'Chicago'
        end

        # there's no validations on LegacyUser?
        xit "cannot create a new user with invalid attributes" do
          api_post :create, :user => {}, token: user.spree_api_key
          expect(response.status).to eq(422)
          expect(json_response["error"]).to eq("Invalid resource. Please fix errors and try again.")
          errors = json_response["errors"]
        end
      end

      describe "#update" do
        it "can update own details" do
          api_put :update, id: user.id, token: user.spree_api_key, user: {
            email: "mine@example.com",
            bill_address_attributes: build(:address, city: "New York").attributes,
            ship_address_attributes: build(:address, city: "Chicago").attributes,
          }
          expect(json_response['email']).to eq 'mine@example.com'
          expect(json_response['bill_address']['city']).to eq 'New York'
          expect(json_response['ship_address']['city']).to eq 'Chicago'
        end

        it "cannot update other users details" do
          api_put :update, id: stranger.id, token: user.spree_api_key, user: { :email => "mine@example.com" }
          assert_not_found!
        end
      end

      describe "#destroy" do
        it "can delete itself" do
          api_delete :destroy, id: user.id, token: user.spree_api_key
          expect(response.status).to eq(204)
        end

        it "cannot delete other user" do
          api_delete :destroy, id: stranger.id, token: user.spree_api_key
          assert_not_found!
        end

        context "with the ability to manage users" do
          before { stub_authentication! }
          sign_in_as_admin!

          it "can destroy user without orders" do
            user.orders.destroy_all
            api_delete :destroy, :id => user.id
            expect(response.status).to eq(204)
          end

          it "cannot destroy user with orders" do
            create(:completed_order_with_totals, :user => user)
            api_delete :destroy, :id => user.id
            expect(json_response["exception"]).to eq "Spree::Core::DestroyWithOrdersError"
            expect(response.status).to eq(422)
          end
        end
      end

      describe "#index" do
        it "should only get own details on index" do
          2.times { create(:user) }
          api_get :index, token: user.spree_api_key

          expect(Spree.user_class.count).to eq 3
          expect(json_response['count']).to eq 1
          expect(json_response['users'].size).to eq 1
        end

        context "with the ability to display users" do
          before do
            user.spree_roles.create!(name: "user_display")
            Spree::RoleConfiguration.configure do |config|
              config.assign_permissions :user_display, [Spree::PermissionSets::UserDisplay]
            end
          end

          it "gets all users" do
            2.times { create(:user) }

            api_get :index, token: user.spree_api_key
            expect(Spree.user_class.count).to eq 3 # our user, plus two more
            expect(json_response['count']).to eq 3
            expect(json_response['users'].size).to eq 3
          end

          it 'can control the page size through a parameter' do
            2.times { create(:user) }
            api_get :index, :per_page => 1, token: user.spree_api_key
            expect(json_response['count']).to eq(1)
            expect(json_response['current_page']).to eq(1)
            expect(json_response['pages']).to eq(3)
          end

          it 'can query the results through a paramter' do
            expected_result = create(:user, :email => 'brian@spreecommerce.com')
            api_get :index, :q => { :email_cont => 'brian' }, token: user.spree_api_key
            expect(json_response['count']).to eq(1)
            expect(json_response['users'].first['email']).to eq expected_result.email
          end
        end
      end
    end
  end
end
