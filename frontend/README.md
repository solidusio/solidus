# solidus\_frontend

Frontend contains controllers and views implementing a storefront and cart for Solidus.

## Override views

In order to customize a view you should copy the file into your host app. Using Deface is not
recommended as it provides lots of headaches while debugging and degrades your shops performance.

Solidus provides a generator to help with copying the right view into your host app.

Simply call the generator to copy all views into your host app.

```shell
$ bundle exec rails g solidus:views:override
```

If you only want to copy certain views into your host app, you can provide the `--only` argument:

```shell
$ bundle exec rails g solidus:views:override --only products/show
```

The argument to `--only` can also be a substring of the name of the view from the `app/views/spree` folder:

```shell
$ bundle exec rails g solidus:views:override --only product
```

This will copy all views whose directory or filename contains the string "product".

### Handle upgrades

After upgrading solidus to a new version run the generator again and follow on screen instructions.

## Testing

Create the test site

    bundle exec rake test_app

Run the tests

    bundle exec rake spec
