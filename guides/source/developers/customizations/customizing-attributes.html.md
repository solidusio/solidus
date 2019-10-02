# Customizing Model Attributes

This guide covers how to add editable attributes to models in Solidus.
We will cover an example of adding a new attribute to the `Spree:Taxon` model 
to allow for an additional text area.

-   Adding attribute columns to the database
-   Adding attribute fields to the admin panel
-   Allowing custom attributes to be saved

## Adding Columns to the Database

Columns can be added to Solidus database tables using standard Rails migrations
[standard Rails migrations][standard_rails_migrations].

If you wanted to add a `more_information` attribute, you could run the 
following command:

```bash
rails generate migration AddMoreInformationToTaxons
``` 

This would create a migration file starting with a timestamp 
`db/migrate/20190925192026_add_more_information_to_taxons.rb`. Then update the 
file with the following contents to add a new text type column 
`more_information` to the table:

```ruby
class AddMoreInformationToTaxons < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_taxons, :more_information, :text
  end
end
```

After you are done editing your migration run the following command to add the 
column to the database:

```bash
rails db:migrate
```

[standard_rails_migrations]: https://guides.rubyonrails.org/active_record_migrations.html

## Adding Fields to the Admin Panel

We have a complete guide on [customizing the admin panel][admin], but will
go over it here briefly for our example. While that guide covers template
replacement and using the [Deface][deface] gem, we'll just cover the 
Deface approach. This allows changing parts of the views without overriding
them entirely.

To add a new form field for a custom attribute to the taxon form, we would
want to extend `app/views/spree/admin/taxons/_form.html.erb` from the 
Solidus backend. We can do that with Deface by creating a file 
`app/overrides/spree/admin/taxons/_form/add_fields.html.erb.deface`.

Below is an example of adding a new field to this form for a `more_information`
field.

```erb
<!-- insert_bottom '[data-hook=admin_inside_taxon_form]' -->
<div class="col-10">
  <%= f.field_container :more_information do %>
    <%= f.label :more_information %><br />
    <%= f.text_area :more_information, class: 'fullwidth', rows: 6 %>
  <% end %>
</div>
```

[admin]: customizing-admin.html
[deface]: https://github.com/spree/deface

## Allowing Custom Attributes to be Saved

If you try to submit the form with the new attribute field, you will notice
it will not save to the database. This is due to every model having a list of
permitted attributes.

To extend this list, we can add the following line to an initializer, for
example in `config/initializers/spree.rb`:

```ruby
Spree::PermittedAttributes.taxon_attributes << [:more_information]
```

This tells Solidus that it's okay to accept values being saved to your custom
attributes. If you were going to do this for multiple attributes, you can
comma separate them.

After this has been added, you will need to reboot your Rails server. Now
you can use the form in the admin panel to manage your custom attribute.
