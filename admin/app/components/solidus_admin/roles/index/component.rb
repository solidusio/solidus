# frozen_string_literal: true

class SolidusAdmin::Roles::Index::Component < SolidusAdmin::BaseComponent
  def initialize(roles:)
    @roles = roles
  end

  # @!visibility private

  def render_permission_sets(permission_sets)
    safe_join(
      permission_sets.map do |permission_set|
        render component('ui.badge').new(
          name: permission_set.name.remove('Spree::PermissionSets::').underscore.humanize
        )
      end
    )
  end
end
