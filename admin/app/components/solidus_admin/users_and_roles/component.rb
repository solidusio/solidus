# frozen_string_literal: true

class SolidusAdmin::UsersAndRoles::Component < SolidusAdmin::UI::Pages::Index::Component
  def title
    page_header_title safe_join([
      tag.div(t(".title"))
    ])
  end

  def tabs
    [
      {
        text: Spree.user_class.model_name.human(count: 2),
        href: solidus_admin.users_path,
        current: model_class == Spree.user_class
      },
      {
        text: Spree::Role.model_name.human(count: 2),
        href: solidus_admin.roles_path,
        current: model_class == Spree::Role
      }
    ]
  end
end
