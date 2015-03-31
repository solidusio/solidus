require 'spec_helper'

module Spree
  describe Api::StockLocationsController, :type => :controller do
    render_views

    let!(:stock_location) { create(:stock_location) }
    let!(:attributes) { [:id, :name, :address1, :address2, :city, :state_id, :state_name, :country_id, :zipcode, :phone, :active] }

    before do
      stub_authentication!
    end

    context "as a user" do
      describe "#index" do
        it "can see active stock locations" do
          api_get :index
          expect(response).to be_success
          stock_locations = json_response['stock_locations'].map { |sl| sl['name'] }
          expect(stock_locations).to include stock_location.name
        end

        it "cannot see inactive stock locations" do
          stock_location.update_attributes!(active: false)
          api_get :index
          expect(response).to be_success
          stock_locations = json_response['stock_locations'].map { |sl| sl['name'] }
          expect(stock_locations).not_to include stock_location.name
        end
      end

      describe "#show" do
        it "can see active stock locations" do
          api_get :show, id: stock_location.id
          expect(response).to be_success
          expect(json_response['name']).to eq stock_location.name
        end

        it "cannot see inactive stock locations" do
          stock_location.update_attributes!(active: false)
          api_get :show, id: stock_location.id
          expect(response).to be_not_found
        end
      end

      describe "#create" do
        it "cannot create a new stock location" do
          params = {
            stock_location: {
              name: "North Pole",
              active: true
            }
          }

          api_post :create, params
          response.status.should == 401
        end
      end

      describe "#update" do
        it "cannot update a stock location" do
          api_put :update, :stock_location => { :name => "South Pole" }, :id => stock_location.to_param
          response.status.should == 401
        end
      end

      describe "#destroy" do
        it "cannot delete a stock location" do
          api_put :destroy, :id => stock_location.to_param
          response.status.should == 401
        end
      end
    end

    context "as an admin" do
      sign_in_as_admin!

      describe "#index" do
        it "can see active stock locations" do
          api_get :index
          expect(response).to be_success
          stock_locations = json_response['stock_locations'].map { |sl| sl['name'] }
          expect(stock_locations).to include stock_location.name
        end

        it "can see inactive stock locations" do
          stock_location.update_attributes!(active: false)
          api_get :index
          expect(response).to be_success
          stock_locations = json_response['stock_locations'].map { |sl| sl['name'] }
          expect(stock_locations).to include stock_location.name
        end

        it "gets stock location information" do
          api_get :index
          json_response['stock_locations'].first.should have_attributes(attributes)
          json_response['stock_locations'].first['country'].should_not be_nil
          json_response['stock_locations'].first['state'].should_not be_nil
        end

        it 'can control the page size through a parameter' do
          create(:stock_location)
          api_get :index, per_page: 1
          json_response['count'].should == 1
          json_response['current_page'].should == 1
          json_response['pages'].should == 2
        end

        it 'can query the results through a paramter' do
          expected_result = create(:stock_location, name: 'South America')
          api_get :index, q: { name_cont: 'south' }
          json_response['count'].should == 1
          json_response['stock_locations'].first['name'].should eq expected_result.name
        end

      end

      describe "#show" do
        it "can see active stock locations" do
          api_get :show, id: stock_location.id
          expect(response).to be_success
          expect(json_response['name']).to eq stock_location.name
        end

        it "can see inactive stock locations" do
          stock_location.update_attributes!(active: false)
          api_get :show, id: stock_location.id
          expect(response).to be_success
          expect(json_response['name']).to eq stock_location.name
        end
      end

      describe "#create" do
        it "can create a new stock location" do
          params = {
            stock_location: {
              name: "North Pole",
              active: true
            }
          }

          api_post :create, params
          response.status.should == 201
          json_response.should have_attributes(attributes)
        end
      end

      describe "#update" do
        it "can update a stock location" do
          params = {
            id: stock_location.to_param,
            stock_location: {
              name: "South Pole"
            }
          }

          api_put :update, params
          response.status.should == 200
          json_response['name'].should eq 'South Pole'
        end
      end

      describe "#destroy" do
        it "can delete a stock location" do
          api_delete :destroy, id: stock_location.to_param
          response.status.should == 204
          lambda { stock_location.reload }.should raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
