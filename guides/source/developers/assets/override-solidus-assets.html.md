# Override Solidus assets

If you use gems that provide assets and views (like the `solidus_frontend` and
`solidus backend` gems), you can override or replace them with your own custom
assets and views.

The custom assets you create for a Solidus extension or the frontend and backend
of a store would not be automatically included and served to clients. For more
information about adding your own custom assets to Solidus, see the
[Asset management][asset-management] article.

This article provides an overview of how Solidus manages assets. Note that it
assumes that you are using the `solidus_frontend` and `solidus_backend` gems
that are included as part of a typical Solidus installation.

[asset-management]: asset-management.html#managing-application-assets

## Overrides and upgrading Solidus

We recommend overriding assets as little as possible. Overriding assets makes
maintaining your application more complicated in the long term.

The `solidus_frontend` and `solidus_backend` gems change with each version, and
overrides for one version might not be effective for the next.

## Override individual CSS or JavaScript definitions

If you want to tweak a CSS definition or change the way a particular JavaScript
methods works, you can override it by redefining the definition in a file in
your application's `app/assets` tree.

### Stylesheets

If you want to override a single style from a stylesheet, you can create a new
stylesheet (for example, `foo.css`) and re-define the same style. Your new
stylesheet, `foo.css`, will be included after the styles set in your gems, which
means it would override any existing definition.

For example, you could override a footer style in `solidus_frontend`'s
[`screen.css.scss`][screen-css-scss] file:

```css
footer#footer {
  padding: 10px 0;
  border-top: $default_border;
}
```

Just create a new stylesheet `your_app/app/assets/stylesheets/spree/frontend/`
called `foo.css` and redefine any selectors that you want to change:

```css
footer#footer {
  border: none;
}
```

If you need to override the global SCSS variables used in `solidus_backend`, you can simply redefine them in the [`variables_override.scss`][variables-override-scss] file. For example:

```scss
// Change the color of a default variable, e.g. $color-dark
$color-dark:          #000;
```
[variables-override-scss]: https://github.com/solidusio/solidus/blob/master/backend/app/assets/stylesheets/spree/backend/globals/_variables_override.scss

[screen-css-scss]: https://github.com/solidusio/solidus/blob/master/frontend/app/assets/stylesheets/spree/frontend/screen.css.scss

### JavaScript

Just like you can override a single CSS definition being provided by a gem, you
can rewrite an existing JavaScript function.

For example, if you wanted to override the `Spree.showVariantImages` method from
`solidus_frontend`'s [`product.js`][product-js], you can do so from any
JavaScript file in your project's assets.

For example, just create a new JavaScript file,
`your_app/app/assets/javascripts/spree/frontend/showVariantImages.js` and
include the new method definition:

```javascript
Spree.showVariantImages = function(variant_id) {
 alert('hello world');
}
```

When your JavaScript gets compiled to `frontend/app.js` and served to clients,
it would it include both `Spree.showVariantImages` methods, but your custom
definition would be the last definition of the method and the one executed on
request.

[product-js]: https://github.com/solidusio/solidus/blob/master/frontend/app/assets/javascripts/spree/frontend/product.js

## Override an image, stylesheet, or JavaScript file

To replace an entire file that is provided by a gem (like `solidus_frontend` or
`solidus_backend`), you can create a new file in your project's `app/assets`
directory that has a corresponding filename and location. You can do this with
any image, stylesheet, or JavaScript file provided by a gem.

For example, to replace the `solidus_frontend`'s
[`_variables.scss`][variables-scss] at
`/app/assets/stylesheets/spree/frontend/_variables.scss` you could save the
replacement to `your_app/app/assets/stylesheets/spree/frontend/_variables.scss`
with your own definitions inside.

This is more brittle than overriding single definitions, as described above,
and isn't guaranteed to work in future Solidus versions.

Note that this method *completely* replaces any functionality provided by the
stylesheet or JavaScript file.

This same method can also be used to override files provided by third-party
extensions.

[variables-scss]: https://github.com/solidusio/solidus/blob/master/frontend/app/assets/stylesheets/spree/frontend/_variables.scss
