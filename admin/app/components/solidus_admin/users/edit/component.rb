# frozen_string_literal: true

class SolidusAdmin::Users::Edit::Component < SolidusAdmin::Resources::Edit::Component
  include SolidusAdmin::Layout::PageHelpers

  def role_options = Spree::Role.all.map { {label: _1.name, id: _1.id} }

  def back_url = solidus_admin.users_path
end
