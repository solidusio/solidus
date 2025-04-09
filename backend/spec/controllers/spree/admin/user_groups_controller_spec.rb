# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::Admin::UserGroupsController, type: :controller do
  stub_authorization!

  let(:user_group) { create(:user_group) }

  describe '#index' do
    it 'retrieves all user groups and assigns them to the view' do
      get :index

      expect(assigns(:user_groups)).to eq([user_group])
    end
  end

  describe '#new' do
    it 'prepares a new user group for the form' do
      get :new

      expect(assigns(:user_group)).to be_a_new(Spree::UserGroup)
    end
  end

  describe '#edit' do
    it 'loads the specified user group for editing' do
      get :edit, params: { id: user_group.id }

      expect(assigns(:user_group)).to eq(user_group)
    end
  end

  describe '#create' do
    context 'with valid params' do
      let(:valid_attributes) { { group_name: 'New User Group' } }

      it 'saves a new user group to the database' do
        expect {
          post :create, params: { user_group: valid_attributes }
        }.to change(Spree::UserGroup, :count).by(1)
      end

      it 'makes the newly created user group available to the view' do
        post :create, params: { user_group: valid_attributes }

        expect(assigns(:user_group)).to be_a(Spree::UserGroup)
        expect(assigns(:user_group)).to be_persisted
      end

      it 'redirects to the user groups list page' do
        post :create, params: { user_group: valid_attributes }

        expect(response).to redirect_to(spree.admin_user_groups_path)
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) { { group_name: nil } }

      it 'does not save the user group and prepares a new instance for the form' do
        post :create, params: { user_group: invalid_attributes }

        expect(assigns(:user_group)).to be_a_new(Spree::UserGroup)
      end

      it 'renders the "new" form again' do
        post :create, params: { user_group: invalid_attributes }

        expect(response).to render_template('new')
      end
    end
  end

  describe '#update' do
    context 'with valid params' do
      let(:new_attributes) { { group_name: 'Updated Group Name' } }

      it 'updates the user group with the provided attributes' do
        put :update, params: { id: user_group.id, user_group: new_attributes }

        user_group.reload

        expect(user_group.group_name).to eq('Updated Group Name')
      end

      it 'makes the updated user group available to the view' do
        put :update, params: { id: user_group.id, user_group: new_attributes }

        expect(assigns(:user_group)).to eq(user_group)
      end

      it 'redirects to the user groups list page' do
        put :update, params: { id: user_group.id, user_group: new_attributes }

        expect(response).to redirect_to(spree.admin_user_groups_path)
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) { { group_name: nil } }

      it 'does not update the user group and keeps the original instance' do
        put :update, params: { id: user_group.id, user_group: invalid_attributes }

        expect(assigns(:user_group)).to eq(user_group)
      end

      it 'renders the "edit" form again' do
        put :update, params: { id: user_group.id, user_group: invalid_attributes }

        expect(response).to render_template('edit')
      end
    end
  end

  describe '#destroy' do
    it 'removes the user group from the database' do
      user_group = create(:user_group)
      expect {
        delete :destroy, params: { id: user_group.id }
      }.to change(Spree::UserGroup, :count).by(-1)
    end

    it 'redirects to the user groups list page' do
      delete :destroy, params: { id: user_group.id }

      expect(response).to redirect_to(spree.admin_user_groups_path)
    end
  end
end
