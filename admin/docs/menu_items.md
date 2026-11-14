# Customizing the Menu

You are allowed to add your custom links to the main navigation. To do so, you can access `SolidusAdmin::Config.menu_items` in an initializer:

```ruby
# config/initializers/solidus_admin.rb
SolidusAdmin::Config.menu_items << {
  key: :my_custom_link,
  route: :my_custom_link_path,
  icon: "24-hours-fill",
  position: 80
}
```

- The key you provide will be used to translate the link's label under the
`solidus_admin.menu_item.#{key}` key.
- Icon needs to be an icon name from [Remixicon](https://remixicon.com/).
- Position tells Solidus where to place the link in the main navigation. The
 default items are placed with 10 points of difference between them.

For nested links, you can provide a `children:` option with an array of hashes:

```ruby
# config/initializers/solidus_admin.rb
SolidusAdmin::Config.configure do |config|
  config.menu_items << {
    key: :my_custom_link,
    route: :my_custom_link_path,
    icon: "24-hours-fill",
    position: 80,
    children: [
      {
        key: :my_custom_nested_link,
        route: :my_custom_nested_link_path,
        position: 80
      }
    ]
  }
end
```

Your custom link will be rendered in the active state when its base path (i.e, the path without the query string) matches the one for the current url.

## Reusing menu items from `solidus_backend`

If your store already customizes the legacy admin menu through
`Spree::Backend::Config.menu_items`, you don't need to define those items a
second time. Call `import_menu_items_from_backend!` and SolidusAdmin will build
its main navigation from the backend configuration:

```ruby
# config/initializers/solidus_admin.rb
SolidusAdmin::Config.configure do |config|
  config.import_menu_items_from_backend!
end
```

Keep the following in mind:

- **The whole menu is replaced.** The imported items take the place of the
  default SolidusAdmin menu, and of anything previously added to
  `config.menu_items`. Add SolidusAdmin-only items after the import.
- **Load order matters.** Backend menu items are read when the method is called,
  so the backend customizations need to be in place first. Initializers run in
  alphabetical order: either add them to a file that sorts before
  `solidus_admin.rb` (e.g. `config/initializers/spree.rb`) or call the import
  from the same initializer, right after them.
- **`solidus_backend` needs to be loaded.** The method reads from
  `Spree::Backend::Config`, so it is only available while your app still
  depends on `solidus_backend`.

### How backend menu items are converted

Each `Spree::BackendConfiguration::MenuItem` becomes a SolidusAdmin menu item:

| Backend (`MenuItem`)   | SolidusAdmin | Notes                                                                                                                                                                                                                                      |
|------------------------|--------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `label`                | `key`        | Translated with `solidus_admin.menu_item.#{key}`, falling back to the humanized key. Backend labels are translated with `spree.admin.tab.#{label}`, so copy your custom labels over to the new scope.                                      |
| `url`                  | `route`      | A `Symbol` is called on the **SolidusAdmin** route helpers, a `String` is used as is, and a `Proc` is evaluated with access to the `spree` and `solidus_admin` route helpers. When there is no `url`, `spree.admin_#{label}_path` is used. |
| `match_path`           | `match_path` | Strings are matched as a prefix of the path, after the admin mount path. Without a `match_path`, the item is active when the current path starts with its own route.                                                                       |
| `icon`                 | `icon`       | Only [Remixicon](https://remixicon.com/) names (`ri-` prefixed) are kept, anything else (e.g. Font Awesome names) falls back to a generic icon.                                                                                            |
| `children`             | `children`   | Converted recursively.                                                                                                                                                                                                                     |
| position in the array  | `position`   | Items keep the order they have in the backend configuration.                                                                                                                                                                               |
| `condition`            | –            | Not imported, see below.                                                                                                                                                                                                                   |
| `partial`, `data_hook` | –            | Not supported: SolidusAdmin menus are data only. Use `children` instead of a partial.                                                                                                                                                      |

Because `condition` is not imported, items are shown to every admin user,
regardless of the permissions checked by the backend. The page the item links
to is still subject to its own authorization.

Since a `Symbol` url is resolved against the SolidusAdmin routes, a backend
item pointing to one of your own legacy routes needs a `Proc` in order to keep
working in both admins:

```ruby
# config/initializers/spree.rb
Spree::Backend::Config.configure do |config|
  config.menu_items << config.class::MenuItem.new(
    label: :my_reports,
    icon: "ri-bar-chart-line",
    url: -> { spree.admin_my_reports_path },
    match_path: "/my_reports"
  )
end
```

```yaml
# config/locales/en.yml
en:
  spree:
    admin:
      tab:
        my_reports: Reports # label in solidus_backend
  solidus_admin:
    menu_item:
      my_reports: Reports # label in solidus_admin
```
