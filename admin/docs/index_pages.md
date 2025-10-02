# Adding index pages

Index pages are common in the admin interface, and they are used to display a list of records for a specific model.

Since these pages often have a similar appearance, we have a dedicated component to build them. This component helps avoid writing repetitive boilerplate code.

## The `index` action

The `index` action is the standard action used to display index pages. It's a standard `GET` action that renders the `index` component.

To support search scopes and filters the controller should include the `SolidusAdmin::ControllerHelpers::Search` module and call
`apply_search_to` as follows:

```ruby
class SolidusAdmin::UsersController < SolidusAdmin::BaseController
  include SolidusAdmin::ControllerHelpers::Search

  def index
    users = apply_search_to(Spree.admin_user_class.order(id: :desc), param: :q)
    # ...
```

For pagination support, the index action should also call the `set_page_and_extract_portion_from` method provided by the `geared_pagination` gem. This method sets the `@page` instance variable to the paginated collection and returns the portion of the collection to be displayed on the current page.

```ruby
def index
  users = apply_search_to(Spree.admin_user_class.order(id: :desc), param: :q)
  set_page_and_extract_portion_from(users)
  # ...
```

Finally, the index action should render the `index` component passing the `@page` instance variable as the `collection` prop.

```ruby
def index
  users = apply_search_to(Spree.admin_user_class.order(id: :desc), param: :q)
  set_page_and_extract_portion_from(users)
  render component('users/index').new(page: @page)
end
```

## The `ui/pages/index` component

The `ui/pages/index` component is an abstract component that provides sensible defaults for index pages. It also offers template methods that can be used to customize the behavior of these pages.

We recommend examining existing index pages and the UI component itself to understand how they work. In this section, we'll cover the most important aspects.

The index component requires only the `page` argument during initialization, all other parameters are provided through template methods.

```ruby
class SolidusAdmin::Users::Index < Solidus::Admin::UI::Pages::Index
  def model_class
    Spree.admin_user_class
  end
end

render component('users/index').new(page: @page)
```

## Batch Actions

Batch actions are operations that can be performed on multiple records simultaneously. The index page internally uses the `ui/table` component and depends on the `batch_actions` method to render the batch actions dropdown.

In the component, batch actions are provided as an array of hashes, with each hash representing a single batch action. Each hash must contain the following keys:

- `label`: the name of the batch action, this will be used as the label of the dropdown item
- `icon`: the remix icon-name to be used as the icon of the dropdown item (see the `ui/icon` component for more information)
- `action`: the name of the action to be performed when the batch action is selected. It can be a URL or a path
- `method`: the HTTP method to be used when performing the action, such as `:delete`

The `batch_actions` method is called in the context of the controller, so you can use any controller method or helper to build the batch actions.

Batch actions will be submitted to the specified action with an `id` parameter containing the IDs of the selected records. Using `id` as the
parameter name allows the same action to support both batch and single-record actions for standard routes.

E.g.

```ruby
# in the component
def batch_actions
  [
    {
      label: "Delete",
      icon: "trash",
      action: solidus_admin.delete_admin_users_path,
      method: :delete
    }
  ]
end
```

```ruby
# in the controller
def delete
  @users = Spree.admin_user_class.where(id: params[:id])
  @users.destroy_all
  flash[:notice] = "Admin users deleted"
  redirect_to solidus_admin.users_path, status: :see_other
end
```

## Search Scopes

Search scopes are used to filter the records displayed on the index page. The index page internally uses the `ui/table` component and relies on the `scopes` method to render the search scope buttons.

In the component, search scopes are provided as an array of hashes, with each hash representing a single search scope. Each hash must contain the following keys:

- `label`: the name of the search scope, used as the label of the button
- `name`: the name of the search scope, sent via `q[scope]` parameter when the button is clicked
- `default`: whether this is the default search scope, used to highlight the button when when the page is loaded

On the controller side, search scopes can be defined with the `search_scope` helper, provided by `SolidusAdmin::ControllerHelpers::Search`. This helper takes a name, an optional `default` keyword argument, and a block. The block will be called with the current scope and should return a new ActiveRecord scope.
E.g.

```ruby
module SolidusAdmin
  class UsersController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    search_scope(:customers, default: true) { _1.left_outer_joins(:role_users).where(role_users: { id: nil }) }
    search_scope(:admin) { _1.joins(:role_users).distinct }
    search_scope(:with_orders) { _1.joins(:orders).distinct }
    search_scope(:without_orders) { _1.left_outer_joins(:orders).where(orders: { id: nil }) }
    search_scope(:all)

    def index
      users = apply_search_to(Spree.admin_user_class.order(id: :desc), param: :q)
      # ...
```

## Filters

Filters are used to narrow down the records displayed on the index page. The index page internally uses the `ui/table/ransack_filter` component and depends on the `filters` method to render the filters dropdown.

In the component, filters are represented as an array of hashes, with each hash representing a single filter. Each hash must contain the following keys:


- `label`: the name of the filter, used as the label in the filter bar
- `attribute`: the name of the ransack-enabled attribute to be filtered
- `predicate`: the name of the ransack predicate to be used, e.g. `eq`, `in`, `cont`
- `options`: an array of options to be used for the filter, in the standard rails form of `[["label", "value"], ...]`

On the controller side it's enough to add ransack support to the index action by including `SolidusAdmin::ControllerHelpers::Search` and calling
`apply_search_to` as explained in the [Index action](#index-action) section.

On the controller side, you simply need to add Ransack support to the index action by including the `SolidusAdmin::ControllerHelpers::Search` module and calling the `apply_search_to` method, as explained in the [Index action](#index-action) section.
