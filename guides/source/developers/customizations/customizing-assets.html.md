# Customizing Assets

This guide covers how Solidus manages its JavaScript, stylesheet, and image
assets and how you can extend and customize them including:

-   Understanding Solidus's use of the Rails asset pipeline
-   Managing application-specific assets
-   Overriding Solidus's core assets

## Asset Pipeline and Solidus

Using asset customization techniques outlined below, you will be able to
adapt all the JavaScript, stylesheets, and images contained in Solidus to
easily provide a fully customized experience.

All Rails applications include an `app/assets` directory. By default Solidus
does not deal with that directory, which could contain other files needed by
your application. All the assets provided by Solidus are imported into the
`vendor/assets` folder.

A typical `vendor/assets` directory for a Solidus application will look like:

    vendor
    |-- assets
        |-- images
        |   |-- spree
        |       |-- frontend
        |       |-- backend
        |-- javascripts
        |   |-- spree
        |       |-- frontend
        |       |   |-- all.js
        |       |-- backend
        |           |-- all.js
        |-- stylesheets
        |   |-- spree
        |       |-- frontend
        |       |   |-- all.css
        |       |-- backend
        |           |-- all.css


As you can see, Solidus generates four top-level manifests (`all.css` &
`all.js`, see above) that require all the Solidus and site-specific
stylesheets/JavaScript files.

For example, here's the content of the
`vendor/assets/stylesheets/frontend/all.css` manifest:

```css
/*
 *= require spree/frontend
 *= require_self
 *= require_tree .
*/
```

As you can see, it requires `spree/frontend` stylesheets from
the solidus gem and all the files under the current path recursively.

The `frontend/all.css` manifest is loaded into the host application via a
standard [stylesheet_link_tag][stylesheet-link-frontend] in the frontend
erb main layout.

This structure allows you to load all the Solidus assets and also gives you
the ability to fully customize them. We'll see how in the next few paragraphs.

[stylesheet-link-frontend]: https://github.com/solidusio/solidus/blob/9ae2ed16bad7e29ea422fab1403118a3a0e66266/frontend/app/views/spree/shared/_head.html.erb#L8

## Overriding Solidus core assets

Overriding or replacing any of Solidus's internal assets is very easy. We
recommend that you replace as little as possible in a given JavaScript or
stylesheet file to help ease future upgrade work required.

The methods listed below work for both frontend and backend. They
also apply to extensions that provide assets.

### Overriding individual CSS styles

For example, let's suppose that you want to change how the footer looks,
which is defined by the following rules:

```css
/* solidus/frontend -> app/assets/stylesheets/spree/frontend/screen.css */

div#footer {
 clear: both;
}
```

You can create a new stylesheet inside
`vendor/assets/stylesheets/spree/frontend/` and include the
following CSS:

```css
/* your_app -> vendor/assets/stylesheets/spree/frontend/foo.css */

div#footer {
 clear: none;
 border: 1px solid red;
}
```


The `frontend/all.css` manifest will automatically include `foo.css`, due to
this directive that includes all the files in the current directory:

```css
/*
 *= require_tree .
*/
```

Now both rules are loaded and standard CSS specificity rules are applied to
determine the final style result for that element. In this case, since the
`require_tree` directive is defined after `require spree/frontend`, our new
rule-set will be evaluated later in the final stylesheet and will take
precedence.

### Overriding entire CSS files

To replace an entire stylesheet provided by Solidus you can simply
create a file with the same name and save it to the corresponding path
within your application's `vendor/assets/stylesheets` directory.

For example, to replace the `spree/frontend/all.css` provided by Solidus,
you would save the replacement to
`vendor/assets/stylesheets/spree/frontend/all.css`.

This same method can also be used to override stylesheets provided by
third-party extensions.

### Overriding individual JavaScript functions

A similar approach can be used for JavaScript functions. For example, if
you wanted to override the `show_variant_images` method:

```javascript
// solidus/frontend -> app/assets/javascripts/spree/frontend/product.js
Spree.ready(function($) {
  //
  // Other code...
  //
  Spree.updateVariantPrice = function(variant) {
    var variantPrice = variant.data("price");
    if (variantPrice) {
      $(".price.selling").text(variantPrice);
    }
  };
  //
  // Other code...
  //
});
```

Again, just create a new JavaScript file inside
`vendor/assets/javascripts/spree/frontend` and include the new method
definition:

```javascript
// your_app -> vendor/assets/javascripts/spree/frontend/foo.js

Spree.ready(function($) {
  Spree.updateVariantPrice = function() {
    alert("Hello World!");
  };
});
```

The resulting `frontend/all.js` would include both methods, with the latter
being the one executed on request.

### Overriding entire JavaScript files

To replace an entire JavaScript file provided by Solidus you can simply create
a file with the same name and save it to the the corresponding path within
your application or extension's `app/assets/javascripts` directory.

For example, to replace the `spree/frontend/all.js` file provided by Solidus,
you would save the replacement to
`vendor/assets/javascripts/spree/frontend/all.js`.

This same method can be used to override JavaScript files provided by
third-party extensions.
