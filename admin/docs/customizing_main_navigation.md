# Customizing the main navigation

You are allowed to add your custom links to the main navigation. To do so, you can access `SolidusAdmin::Config.main_nav` in an initializer:

```ruby
# config/initializers/solidus_admin.rb
SolidusAdmin::Config.configure do |config|
  config.main_nav do |main_nav|
    main_nav.add(
      key: :my_custom_link,
      route: :my_custom_link_path,
      icon: "solidus_admin/my_custom_link.svg",
      position: 80
    )
  end
end
```

- The key you provide will be used to translate the link's label under the
`solidus_admin.main_nav.#{key}` key. 
- Icon needs to be a path to a SVG file accessible from the asset pipeline.
- Position tells Solidus where to place the link in the main navigation. The
 default items are placed with 10 points of difference between them.

For nested links, you can provide a `children:` option with an array of hashes:

```ruby
# config/initializers/solidus_admin.rb
SolidusAdmin::Config.configure do |config|
  config.main_nav do |main_nav|
    main_nav.add(
      key: :my_custom_link,
      route: :my_custom_link_path,
      icon: "solidus_admin/my_custom_link.svg",
      position: 80,
      children: [
        {
          key: :my_custom_nested_link,
          route: :my_custom_nested_link_path,
          position: 80
        }
      ]
    )
  end
end
```

Your custom link will be rendered in the active state when its base path (i.e, the path without the query string) matches the one for the current url.
