# frozen_string_literal: true

namespace :solidus do
  desc "Import existing permission sets to role permissions table"
  task import_existing_permission_sets: :environment do
    Zeitwerk::Loader.eager_load_all unless Rails.env.test?

    ActiveRecord::Base.transaction do
      Spree::PermissionSets::Base.descendants.each do |permission|
        Spree::PermissionSet.find_or_create_by(name: permission.to_s, group: permission.to_s.split("PermissionSets::").last.gsub(/Display|Management/i, ""))
      end

      Spree::AppConfiguration.new.roles.roles.each do |role_name, role_config|
        role_config.permission_sets.each do |set|
          role = Spree::Role.find_or_create_by(name: role_name)
          permission_set = Spree::PermissionSet.find_by(name: set.name)

          if permission_set
            Spree::RolePermission.find_or_create_by!(
              role: role,
              permission_set: permission_set
            )
          else
            puts "#{set} was not found."
          end
        end
      end
    end
  end
end
