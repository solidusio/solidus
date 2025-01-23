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
    solidus_admin.edit_role_path(role, **search_filter_params)
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: solidus_admin.new_role_path(**search_filter_params),
      data: { turbo_frame: :resource_modal },
      icon: "add-line",
    )
  end

  def turbo_frames
    %w[
      resource_modal
    ]
  end

  def batch_actions
    [
      {
        label: t('.batch_actions.delete'),
        action: solidus_admin.roles_path(**search_filter_params),
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
            data: { turbo_frame: :resource_modal },
            class: "body-link"
        end,
      },
      {
        header: :description,
        data: ->(role) do
          link_to_if role.description, role.description, edit_path(role),
            data: { turbo_frame: :resource_modal },
            class: "body-link"
        end
      }
    ]
  end
end
