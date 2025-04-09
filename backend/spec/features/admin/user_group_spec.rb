# frozen_string_literal: true

require 'spec_helper'

describe 'User Groups', type: :feature do
  stub_authorization!

  let!(:user_group) { create :user_group, group_name: 'Default Group' }

  context 'when adding a user group' do
    before { visit spree.new_admin_user_group_path }

    it 'admin should be able to create a user group' do
      fill_in 'user_group_group_name', with: 'VIP Group'
      click_button 'Create'

      @user_group = Spree::UserGroup.last

      expect(@user_group.group_name).to eq 'VIP Group'
    end
  end

  context 'when editing a user group' do
    before { visit spree.edit_admin_user_group_path(user_group) }

    it 'admin should be able to change the group name' do
      fill_in 'user_group_group_name', with: 'Updated Group'
      click_button 'Update'

      expect(user_group.reload.group_name).to eq 'Updated Group'
    end
  end

  context 'when deleting a user group' do
    before { visit spree.admin_user_groups_path }

    it 'admin should be able to delete a user group', js: true do
      within("#spree_user_group_#{user_group.id}") do
        accept_alert do
            click_icon :trash
        end
      end

      expect(page).not_to have_content(user_group.group_name)
      expect(Spree::UserGroup.exists?(user_group.id)).to be_falsey
    end
  end
end
