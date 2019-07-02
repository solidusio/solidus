# Admin Panel Customizations

Implementing a Solidus store, you may need to change how the Admin Panel works.
Solidus allows the full customization of your store Admin Panel (also referred
to as backend) and this page shows how to implement frequently requested changes.

## Views

At the moment there are two ways of changing an Admin Panel view:

### Override the Views (Template Replacement)

You can override original views by creating a file in your host application
with the same path of the one you want to change, copy/pasting the content of
the original file into the new one and editing it.

For example, if you want to customize
[backend/app/views/spree/admin/orders/index.html.erb][orders/index], you have
to create a new file at `app/views/spree/admin/orders/index.html.erb`, copy
the original content into it and change the relevant part.

Please, be sure to copy the file corresponding to the version of Solidus that
you are using: once you've identified your version (usually through your Gemfile),
you can switch to the right branch using the branch selector in the GitHub UI.

<!-- TOOD: add the GitHub branch selector image -->

The disadvantages of this approach are that, if that view changes in a future
version of Solidus, you could have problems since your view code does not
match with the rest of the Solidus codebase at the newer version.

### Use Deface

[Deface][deface] is a gem that allows changing part of your views without
overriding them entirely and it was born to fix the issue described in the
previous approach.

#### Usage

Suppose you want to customize
[backend/app/views/spree/admin/orders/index.html.erb][orders/index], changing
the following block:

```erb
<div class="no-objects-found">
  <%= render 'spree/admin/shared/no_objects_found',
               resource: Spree::Order,
               new_resource_url: spree.new_admin_order_path %>
</div>
```

into:

```erb
<div class="no-objects-found">
  <h2>No Order found</h2>
</div>
```

With deface you can to create a new file at
`app/overrides/spree/admin/orders/index/replace_no_object_found.html.erb.deface`
that will describe the change you want to make to original erb file, For example:

```erb
<!--
  replace_contents ".no-objects-found"
-->

<div class="no-objects-found">
  <h2>No Order found</h2>
</div>
````

Before rendering the original view, Deface will modify its content following
the instructions contained in the `.deface` file.

Check out the Deface [documentation][deface] for more information
about the provided DSL and other usage examples.

Upgrading to a newer version of Solidus, view modifications done with Deface
are less likely to break your store, since only a small part of the view has
been changed, but this approach has some downsides as well:

- if multiple extensions change the same part of the view, you can have
  unexpected results
- while debugging, finding if and which Deface override is changing a specific
  part of the view could be time-consuming

[orders/index]: https://github.com/solidusio/solidus/blob/master/backend/app/views/spree/admin/orders/index.html.erb
[deface]: https://github.com/spree/deface

## Menu Items

Often, when adding new pages to the Admin Panel, there's the need to add
a new item in the main menu to reach the newly added pages.

It's easy to add new menu items, just add the following lines in the
`config/initializers/spree.rb` initializer:

```rb
Spree::Backend::Config.configure do |config|
  config.menu_items << config.class::MenuItem.new(
    [:section],
    'icon-name',
    url: 'https://solidus.io/'
  )
end
```

See [Spree::BackendConfiguration::MenuItem][menu-item-doc] documentation
for more information about menu items customizations.

[menu-item-doc]: http://docs.solidus.io/Spree/BackendConfiguration/MenuItem.html

## Search Forms

Admin UI has a search form in nearly all pages that list resources items, for
example `/admin/orders`.

<!-- TODO: add an admin/orders screenshot where search is visible -->

These forms come with a set of fields that we can use to perform the search
against. Technically, they are just an interface to use the [ransack][ransack]
gem.

To add a new field you need to change the view that contains the search form,
in this case [`app/views/spree/admin/orders/index.html.erb`][orders/index] and
add a new form input wherever you think it fits better.

Please read the [Views](#views) paragraph to understand how to change the
original template.

For example, if you want to add a search field that allows you to filter orders
completed with a specific IP address, you need to add the following field in
the search form:

```erb
<div class="field">
  <%= label_tag :q_last_ip_address_eq, t('spree.email_contains') %>
  <%= f.text_field :last_ip_address_eq %>
</div>
```

`last_ip_address_eq` is part of a matchers DSL provided by [ransack][ransack],
see its documentation for more information.

Additionally, for security reasons, you need to whitelist the new attribute
needed for the search using a specific method provided by [ransack][ransack].
This can be easily done by adding the following line into the
`config/initializers/spree.rb` initializer:

```rb
Spree::Order.whitelisted_ransackable_attributes << 'last_ip_address'
```

[ransack]: https://github.com/activerecord-hackery/ransack
[orders/index]: https://github.com/solidusio/solidus/blob/master/backend/app/views/spree/admin/orders/index.html.erb
