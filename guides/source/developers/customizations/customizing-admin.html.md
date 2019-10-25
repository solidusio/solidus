# Admin Panel Customizations

When developing a Solidus store you may need to change how the Admin Panel works.
Solidus allows you to fully customize your store's Admin Panel (also referred
to as the "backend"). This page shows you how to implement frequently requested changes.

## Views

There are two ways of changing an Admin Panel view:

### Override the Views (Template Replacement)

You can override the original views by creating a file in your host application
with the same path as the one you want to change. Copy and paste the contents of
the original file into the new one and edit it.

For example, if you want to customize
[backend/app/views/spree/admin/orders/index.html.erb][orders/index], simply
create a new file at `app/views/spree/admin/orders/index.html.erb` and copy
the original contents into it. Make any desired changes to the newly copied file. Solidus
will pick up the modified version of the file in your repository, and display
the changes in the backend.

It is important to be sure you are copying the file that corresponds to the
version of Solidus that you are using. For example, if your production store
uses Solidus 2.8, you must copy the files from the 2.8 branch. Once you've
identified your version (usually through your Gemfile), you can switch to the
right branch using the branch selector in the GitHub UI.

<!-- TODO: add the GitHub branch selector image -->

There is one disadvantage to this approach: If your modified view changes in a
future version of Solidus, you could face unexpected problems since your view code does not
match with the rest of the Solidus codebase in the newer version.

### Use Deface

[Deface][deface] is a gem that allows you to selectively change part of your
views without overriding them entirely. It was created to fix the disadvantage 
described in the previous approach.

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

With deface you can create a new file at
`app/overrides/spree/admin/orders/index/replace_no_object_found.html.erb.deface`
and use Deface's DSL to change only part of the original erb file, like so:

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

The benefit is that view modifications made with Deface are less likely to break
your store when you upgrade to future versions of Solidus, since only a small
part of the view has been changed. This approach has some downsides as well,
though:

- If multiple extensions change the same part of the view, there may be
  unexpected conflicts
- Using deface might make debugging more difficult. Finding exactly which Deface
  override is changing a specific part of the view may be time-consuming

[orders/index]: https://github.com/solidusio/solidus/blob/master/backend/app/views/spree/admin/orders/index.html.erb
[deface]: https://github.com/spree/deface

## Menu Items

When adding new pages to the Admin Panel you will often need to add a new
item in the main menu to reach the newly added pages.

It's easy to add new menu items. Just add the following lines in the
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

The admin UI has a search form in nearly every page that lists resource items. For
example `/admin/orders`.

<!-- TODO: add an admin/orders screenshot where search is visible -->

These forms come with a set of fields that we can use to search against.
Technically, they are just an interface to use the [ransack][ransack] gem.

To add a new field you need to change the view that contains the search form.
In this case you change
[`app/views/spree/admin/orders/index.html.erb`][orders/index] and add a new form
input wherever you think it fits best.

Please read the [Views](#views) paragraph to understand how to change the
original template.

For example, if you want to add a search field that allows you to filter orders
completed with a specific IP address, just add the following field in the search
form:

```erb
<div class="field">
  <%= label_tag :q_last_ip_address_eq, t('spree.email_contains') %>
  <%= f.text_field :last_ip_address_eq %>
</div>
```

`last_ip_address_eq` is part of a matchers DSL provided by [ransack][ransack].
See the ransack documentation for more information.

Additionally, for security reasons you will need to whitelist the new attribute
needed for the search. You do this by using a specific method provided by
[ransack][ransack].  This can be easily done by adding the following line into
the `config/initializers/spree.rb` initializer:

```rb
Spree::Order.whitelisted_ransackable_attributes << 'last_ip_address'
```

[ransack]: https://github.com/activerecord-hackery/ransack
[orders/index]: https://github.com/solidusio/solidus/blob/master/backend/app/views/spree/admin/orders/index.html.erb
