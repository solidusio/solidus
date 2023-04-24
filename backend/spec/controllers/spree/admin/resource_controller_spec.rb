# frozen_string_literal: true

require 'spec_helper'

module Spree
  module Admin
    class WidgetsController < Spree::Admin::ResourceController
      prepend_view_path('spec/test_views')

      def model_class
        Widget
      end
    end
  end
end

describe Spree::Admin::WidgetsController, type: :controller do
  stub_authorization!

  # RESOURCE FIXTURE
  before(:all) do
    # Database
    class CreateWidgets < ActiveRecord::Migration[5.1]
      def change
        create_table(:widgets) do |t|
          t.string :name
          t.integer :position
          t.timestamps null: false
        end
      end
    end
    CreateWidgets.migrate(:up)

    # Model
    class Widget < ActiveRecord::Base
      acts_as_list
      validates :name, presence: true
      before_destroy :check_destroy_constraints

      def check_destroy_constraints
        return unless name == 'undestroyable'
        errors.add :base, "You can't destroy undestroyable things!"
        errors.add :base, "Terrible things might happen."
        throw(:abort)
      end
    end

    # Routes
    Spree::Core::Engine.routes.draw do
      namespace :admin do
        resources :widgets do
          post :update_positions, on: :member
        end
      end
    end
  end

  after(:all) do
    # Database
    CreateWidgets.migrate(:down)
    Object.send(:remove_const, :CreateWidgets)

    # Model
    Object.send(:remove_const, :Widget)

    # Controller
    Spree::Admin.send(:remove_const, :WidgetsController)

    # Routes
    Rails.application.reload_routes!
  end

  describe '#new' do
    subject do
      get :new
    end

    it 'succeeds' do
      subject
      expect(response).to be_successful
    end
  end

  describe '#edit' do
    let(:widget) { Widget.create!(name: 'a widget') }

    subject do
      get :edit, params: { id: widget.to_param }
    end

    it 'succeeds' do
      subject
      expect(response).to be_successful
    end
  end

  describe '#create' do
    let(:params) do
      { widget: { name: 'a widget' } }
    end

    subject { post :create, params: params }

    it 'creates the resource' do
      expect { subject }.to change { Widget.count }.by(1)
    end

    context 'failure' do
      let(:params) do
        { widget: { name: '' } } # blank name generates an error
      end

      it 'sets a flash error' do
        subject
        expect(flash[:error]).to eq assigns(:widget).errors.full_messages.join(', ')
      end
    end

    context 'without any parameters' do
      let(:params) { {} }

      before do
        allow_any_instance_of(Widget).to receive(:name).and_return('some name')
      end

      it 'creates the resource' do
        expect { subject }.to change { Widget.count }.by(1)
      end
    end
  end

  describe '#update' do
    let(:widget) { Widget.create!(name: 'a widget') }

    let(:params) do
      {
        id: widget.to_param,
        widget: { name: 'widget renamed' }
      }
    end

    subject { put :update, params: params }

    it 'updates the resource' do
      expect { subject }.to change { widget.reload.name }.from('a widget').to('widget renamed')
    end

    context 'failure' do
      let(:params) do
        {
          id: widget.to_param,
          widget: { name: '' }, # a blank name will trigger a validation error
        }
      end

      it 'sets a flash error' do
        subject
        expect(flash[:error]).to eq assigns(:widget).errors.full_messages.join(', ')
      end
    end

    context 'resource invalid' do
      before do
        allow_any_instance_of(Widget).to receive(:update).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'returns to edit page with error' do
        put :update, params: params
        expect(flash[:error]).to eq('Record invalid')
      end
    end
  end

  describe '#destroy' do
    let!(:widget) { Widget.create!(name: 'a widget') }
    let(:params) { { id: widget.id } }

    subject {
      delete :destroy, params: params
    }

    it 'destroys the resource' do
      expect { subject }.to change { Widget.count }.from(1).to(0)
    end

    context 'failure' do
      let(:widget) { Widget.create!(name: 'undestroyable') }
      let(:params) { { id: widget.id } }

      context 'js format' do
        subject { delete :destroy, params: params, format: 'js' }

        it 'responds with error message' do
          subject
          expect(response).to be_unprocessable
          expect(response.body).to eq assigns(:widget).errors.full_messages.to_sentence
        end
      end

      context 'html format' do
        subject { delete :destroy, params: params }

        it 'responds with error message' do
          subject
          expect(response).to be_redirect
          expect(flash[:error]).to eq assigns(:widget).errors.full_messages.to_sentence
        end
      end
    end
  end

  describe '#update_positions' do
    let(:widget_1) { Widget.create!(name: 'widget 1', position: 1) }
    let(:widget_2) { Widget.create!(name: 'widget 2', position: 2) }

    subject do
      post :update_positions, params: { id: widget_1.to_param,
        positions: { widget_1.id => '2', widget_2.id => '1' }, format: 'js' }
    end

    it 'updates the position of widget 1' do
      expect { subject }.to change { widget_1.reload.position }.from(1).to(2)
    end

    it 'updates the position of widget 2' do
      expect { subject }.to change { widget_2.reload.position }.from(2).to(1)
    end

    context 'passing a not persisted item' do
      subject do
        post :update_positions, params: { id: widget_1.to_param,
          positions: { widget_1.id => '2', widget_2.id => '1', 'widget' => '3' }, format: 'js' }
      end

      it 'only updates the position of persisted attributes' do
        subject
        expect(Widget.all.order('position')).to eq [widget_2, widget_1]
      end
    end

    context "with take care of acts_as_list's after update callback" do
      let(:widget_1) { Widget.create!(id: 4, name: 'widget 4', position: 1) }
      let(:widget_2) { Widget.create!(id: 2, name: 'widget 3', position: 2) }
      let(:widget_3) { Widget.create!(id: 1, name: 'widget 2', position: 3) }
      let(:widget_4) { Widget.create!(id: 3, name: 'widget 1', position: 4) }

      subject do
        post :update_positions, params: { id: widget_1.to_param,
          positions: { widget_3.id => '4', widget_2.id => '3', widget_4.id => '1', widget_1.id => '2' }, format: 'js' }
      end

      it 'updates the position of all widgets' do
        subject
        expect(Widget.all.order('position').map(&:id)).to eq [widget_4, widget_1, widget_2, widget_3].map(&:id)
      end

      context "not passing all elements" do
        subject do
          post :update_positions, params: { id: widget_1.to_param,
            positions: { widget_3.id => '1', widget_2.id => '2', widget_4.id => '3' }, format: 'js' }
        end

        it 'updates the position of all widgets' do
          widget_1 # trigger the creation
          widget_2 # trigger the creation
          widget_3 # trigger the creation
          widget_4 # trigger the creation
          expect(Widget.all.order('position').map(&:id)).to eq [widget_1, widget_2, widget_3, widget_4].map(&:id)
          subject
          expect(Widget.all.order('position').pluck(:position).uniq).to eq [1, 2, 3, 4] # trivial test to show no duplicate position integer
          expect(Widget.all.order('position').map(&:id)).to eq [widget_3, widget_2, widget_4, widget_1].map(&:id)
        end
      end
    end
  end

  describe 'rescue_from ActveRecord::RecordNotFound' do
    let(:widget) { Widget.create!(name: 'a widget') }

    subject do
      get :edit, params: { id: widget.to_param }
    end

    it 'shows an error message with a reference to the model that was not found and redirect to the collection' do
      allow(controller).to receive(:edit) { Spree::Product.find(123) }

      subject

      expect(response).to redirect_to('/admin/widgets')
      expect(flash[:error]).to eql('Product is not found')
    end
  end
end
