# frozen_string_literal: true

require 'spec_helper'

module Spree
  module Api
    class WidgetsController < Spree::Api::ResourceController
      def model_class
        Widget
      end
    end
  end

  describe Api::WidgetsController, type: :controller do
    after(:all) do
      Rails.application.reload_routes!
    end

    with_model 'Widget', scope: :all do
      table do |widget|
        widget.datetime :deleted_at
        widget.timestamps null: false
      end

      model do
        include Spree::SoftDeletable
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

    describe "#destroy" do
      let(:widget) { Widget.create! }

      it "soft-deletes the widget" do
        delete :destroy, params: { id: widget.to_param, token: admin_user.spree_api_key }, as: :json
        expect(response.status).to eq 204

        expect { Widget.find(widget.id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect(Widget.with_discarded.find(widget.id)).to eq(widget)
      end
    end
  end
end
