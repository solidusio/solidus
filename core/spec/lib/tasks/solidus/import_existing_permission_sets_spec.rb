# frozen_string_literal: true

require 'rails_helper'

path = Spree::Core::Engine.root.join('lib/tasks/solidus/import_existing_permission_sets.rake')

RSpec.describe 'solidus' do
  describe 'import_existing_permission_sets' do
    include_context(
      'rake',
      task_path: path,
      task_name: 'solidus:import_existing_permission_sets'
    )

    it 'creates permission sets' do
      expect(Spree::PermissionSet.pluck(:name)).to eq([])

      task.invoke

      expect(Spree::PermissionSet.pluck(:name)).to eq(Spree::PermissionSets::Base.subclasses.map(&:to_s))
    end

    context 'when there is a custom role' do
      let(:role_name) { :customer_service }
      let(:permissions) { ['Spree::PermissionSets::OrderDisplay', 'Spree::PermissionSets::UserDisplay', 'Spree::PermissionSets::ProductDisplay'] }

      before do
        roles = Spree::RoleConfiguration.new.tap do |role|
          role.assign_permissions :default, ['Spree::PermissionSets::DefaultCustomer']
          role.assign_permissions :admin, ['Spree::PermissionSets::SuperUser']
          role.assign_permissions role_name, permissions
        end

        allow_any_instance_of(Spree::AppConfiguration).to receive(:roles).and_return(roles)
      end

      it 'creates the new role with permissions' do
        expect(Spree::Role.find_by(name: role_name.to_s)).not_to be_present

        task.invoke

        role = Spree::Role.find_by(name: role_name.to_s)
        expect(role).to be_present
        expect(role.permission_sets.pluck(:name)).to match_array(permissions)
      end
    end

    context 'when permission set is not found' do
      it 'prints out the missing permission set' do
        allow(Spree::PermissionSet).to receive(:find_by).and_return(nil)

        expect { task.invoke }.to output(a_string_including('Spree::PermissionSets::DefaultCustomer')).to_stdout
      end
    end
  end
end
