require 'spec_helper'

module Spree
  module Api
    class WidgetsController < Solidus::Api::ResourceController
      prepend_view_path('spec/test_views')

      def model_class
        Widget
      end

      def permitted_widget_attributes
        [:name]
      end
    end
  end

  describe Api::WidgetsController, type: :controller do
    render_views

    after(:all) do
      Rails.application.reload_routes!
    end

    with_model 'Widget', scope: :all do
      table do |t|
        t.string :name
        t.integer :position
        t.timestamps null: false
      end

      model do
        acts_as_list
        validates :name, presence: true
      end
    end

    before do
      Solidus::Core::Engine.routes.draw do
        namespace :api do
          resources :widgets
        end
      end
    end

    let(:user) { create(:user, :with_api_key) }
    let(:admin_user) { create(:admin_user, :with_api_key) }

    describe "#index" do
      let!(:widget) { Widget.create!(name: "a widget") }

      it "returns no widgets" do
        api_get :index, token: user.solidus_api_key
        expect(response).to be_success
        expect(json_response['widgets']).to be_blank
      end

      context "it has authorization to read widgets" do
        it "returns widgets" do
          api_get :index, token: admin_user.solidus_api_key
          expect(response).to be_success
          expect(json_response['widgets']).to include(
            'name' => 'a widget',
            'position' => 1
          )
        end
      end
    end

    describe "#show" do
      let(:widget) { Widget.create!(name: "a widget") }

      it "returns not found" do
        api_get :show, id: widget.to_param, token: user.solidus_api_key
        assert_not_found!
      end

      context "it has authorization read widgets" do
        it "returns widget details" do
          api_get :show, id: widget.to_param, token: admin_user.solidus_api_key
          expect(response).to be_success
          expect(json_response['name']).to eq 'a widget'
        end
      end
    end

    describe "#new" do
      it "returns unauthorized" do
        api_get :new, token: user.solidus_api_key
        expect(response).to be_unauthorized
      end

      context "it is allowed to view a new widget" do
        it "can learn how to create a new widget" do
          api_get :new, token: admin_user.solidus_api_key
          expect(response).to be_success
          expect(json_response["attributes"]).to eq(['name'])
        end
      end
    end

    describe "#create" do
      it "returns unauthorized" do
        expect {
          api_post :create, widget: { name: "a widget" }, token: user.solidus_api_key
        }.not_to change(Widget, :count)
        expect(response).to be_unauthorized
      end

      context "it is authorized to create widgets" do
        it "can create a widget" do
          expect {
            api_post :create, widget: { name: "a widget" }, token: admin_user.solidus_api_key
          }.to change(Widget, :count).by(1)
          expect(response).to be_created
          expect(json_response['name']).to eq 'a widget'
          expect(Widget.last.name).to eq 'a widget'
        end
      end
    end

    describe "#update" do
      let!(:widget) { Widget.create!(name: "a widget") }
      it "returns unauthorized" do
        api_put :update, id: widget.to_param, widget: { name: "another widget" }, token: user.solidus_api_key
        assert_not_found!
        expect(widget.reload.name).to eq 'a widget'
      end

      context "it is authorized to update widgets" do
        it "can update a widget" do
          api_put :update, id: widget.to_param, widget: { name: "another widget" }, token: admin_user.solidus_api_key
          expect(response).to be_success
          expect(json_response['name']).to eq 'another widget'
          expect(widget.reload.name).to eq 'another widget'
        end
      end
    end

    describe "#destroy" do
      let!(:widget) { Widget.create!(name: "a widget") }
      it "returns unauthorized" do
        api_delete :destroy, id: widget.to_param, token: user.solidus_api_key
        assert_not_found!
        expect { widget.reload }.not_to raise_error
      end

      context "it is authorized to destroy widgets" do
        it "can destroy a widget" do
          api_delete :destroy, id: widget.to_param, token: admin_user.solidus_api_key
          expect(response.status).to eq 204
          expect { widget.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
