# frozen_string_literal: true

require 'spec_helper'

module Spree
  module Api
    class WidgetsController < Spree::Api::ResourceController
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
      table do |widget|
        widget.string :name
        widget.integer :position
        widget.timestamps null: false
      end

      model do
        acts_as_list
        validates :name, presence: true
      end
    end

    before do
      Spree::Core::Engine.routes.draw do
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
        get :index, params: { token: user.spree_api_key }, as: :json
        expect(response).to be_successful
        expect(json_response['widgets']).to be_blank
      end

      context "it has authorization to read widgets" do
        it "returns widgets" do
          get :index, params: { token: admin_user.spree_api_key }, as: :json
          expect(response).to be_successful
          expect(json_response['widgets']).to include(
            hash_including(
              'name' => 'a widget',
              'position' => 1
            )
          )
        end

        context "specifying ids" do
          let!(:widget2) { Widget.create!(name: "a widget") }

          it "returns both widgets from comma separated string" do
            get :index, params: { ids: [widget.id, widget2.id].join(','), token: admin_user.spree_api_key }, as: :json
            expect(response).to be_successful
            expect(json_response['widgets'].size).to eq 2
          end

          it "returns both widgets from multiple arguments" do
            get :index, params: { ids: [widget.id, widget2.id], token: admin_user.spree_api_key }, as: :json
            expect(response).to be_successful
            expect(json_response['widgets'].size).to eq 2
          end

          it "returns one requested widgets" do
            get :index, params: { ids: widget2.id.to_s, token: admin_user.spree_api_key }, as: :json
            expect(response).to be_successful
            expect(json_response['widgets'].size).to eq 1
            expect(json_response['widgets'][0]['id']).to eq widget2.id
          end

          it "returns no widgets if empty" do
            get :index, params: { ids: '', token: admin_user.spree_api_key }, as: :json
            expect(response).to be_successful
            expect(json_response['widgets']).to be_empty
          end
        end
      end
    end

    describe "#show" do
      let(:widget) { Widget.create!(name: "a widget") }

      it "returns not found" do
        get :show, params: { id: widget.to_param, token: user.spree_api_key }, as: :json
        assert_not_found!
      end

      context "it has authorization read widgets" do
        it "returns widget details" do
          get :show, params: { id: widget.to_param, token: admin_user.spree_api_key }, as: :json
          expect(response).to be_successful
          expect(json_response['name']).to eq 'a widget'
        end
      end
    end

    describe "#new" do
      it "returns unauthorized" do
        get :new, params: { token: user.spree_api_key }, as: :json
        expect(response).to be_unauthorized
      end

      context "it is allowed to view a new widget" do
        it "can learn how to create a new widget" do
          get :new, params: { token: admin_user.spree_api_key }, as: :json
          expect(response).to be_successful
          expect(json_response["attributes"]).to eq(['name'])
        end
      end
    end

    describe "#create" do
      it "returns unauthorized" do
        expect {
          post :create, params: { widget: { name: "a widget" }, token: user.spree_api_key }, as: :json
        }.not_to change(Widget, :count)
        expect(response).to be_unauthorized
      end

      context "it is authorized to create widgets" do
        it "can create a widget" do
          expect {
            post :create, params: { widget: { name: "a widget" }, token: admin_user.spree_api_key }, as: :json
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
        put :update, params: { id: widget.to_param, widget: { name: "another widget" }, token: user.spree_api_key }, as: :json
        assert_not_found!
        expect(widget.reload.name).to eq 'a widget'
      end

      context "it is authorized to update widgets" do
        it "can update a widget" do
          put :update, params: { id: widget.to_param, widget: { name: "another widget" }, token: admin_user.spree_api_key }, as: :json
          expect(response).to be_successful
          expect(json_response['name']).to eq 'another widget'
          expect(widget.reload.name).to eq 'another widget'
        end
      end
    end

    describe "#destroy" do
      let!(:widget) { Widget.create!(name: "a widget") }
      it "returns unauthorized" do
        delete :destroy, params: { id: widget.to_param, token: user.spree_api_key }, as: :json
        assert_not_found!
        expect { widget.reload }.not_to raise_error
      end

      context "it is authorized to destroy widgets" do
        it "can destroy a widget" do
          delete :destroy, params: { id: widget.to_param, token: admin_user.spree_api_key }, as: :json
          expect(response.status).to eq 204
          expect { widget.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
