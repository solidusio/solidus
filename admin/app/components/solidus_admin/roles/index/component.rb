# frozen_string_literal: true

class SolidusAdmin::Roles::Index::Component < SolidusAdmin::UsersAndRoles::Component
  def model_class
    Spree::Role
  end

  def search_key
    :name_cont
  end

  def search_url
    solidus_admin.roles_path
  end

  def edit_path(role)
    solidus_admin.edit_role_path(role)
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: solidus_admin.new_role_path, data: {
        turbo_frame: :new_role_modal,
        turbo_prefetch: false,
      },
      icon: "add-line",
    )
  end

  def turbo_frames
    %w[
      new_role_modal
      edit_role_modal
    ]
  end

  def batch_actions
    [
      {
        label: t('.batch_actions.delete'),
        action: solidus_admin.roles_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def scopes
    [
      { name: :all, label: t('.scopes.all'), default: true },
      { name: :admin, label: t('.scopes.admin') },
    ]
  end

  def filters
    []
  end

  def columns
    [
      {
        header: :role,
        data: ->(role) do
          link_to role.name, edit_path(role),
            data: { turbo_frame: :edit_role_modal, turbo_prefetch: false },
            class: "body-link"
        end,
      },
      {
        header: :description,
        data: ->(role) do
          link_to_if role.description, role.description, edit_path(role),
            data: { turbo_frame: :edit_role_modal, turbo_prefetch: false },
            class: "body-link"
        end
      }
    ]
  end
end
