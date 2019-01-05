# Asset management

Solidus leverages [the Rails asset pipeline][rails-assets-pipeline] to allow for
extension and customization of your frontend and backend assets. We recommend
that you familiarize yourself with the Rails asset pipeline before you begin
modifying or overwriting Solidus's stock assets.

This article provides an overview of how Solidus manages assets. Note that it
assumes that you are using the `solidus_frontend` and `solidus_backend` gems
that are included as part of a typical Solidus installation.

## Quick start

For more information about the asset pipeline, see the sections below. Here's a
point-form summary of how you can get started with assets:

- External JavaScript libraries, stylesheets, and image should be located in the
  `vendor/assets` directory. Otherwise, add custom assets to your project's
  `app/assets` tree.
- Manifests (the `all.css`, `all.js`, and `application.js` files in your
  project's `assets` trees) requires your app's external libraries or custom
  assets – including any files or directories you add deeper in the
  directory tree.
- You can override assets provided by the `solidus_frontend` and
  `solidus_backend` gems, or any other gems. See the [Override Solidus
  assets](override-solidus-assets.html) article for more information.

## Solidus's asset pipeline

Every Solidus application includes standard Rails assets directories:

- `app/assets`
- `lib/assets`
- `vendor/assets`

Asset trees are divided into subdirectories according to their types: either
`images`, `javascripts`, or `stylesheets`.

Solidus takes this further by scoping each asset type by `spree/frontend` or
`spree/backend`, depending on where the asset is being used.

The structure for the `app` and `vendor` trees looks like this:

```
app|vendor
└─ assets
    └─ images
    |   └─ spree
    |       └─ frontend
    |       └─ backend
    ├─ javascripts
    |   └─ spree
    |       └─ frontend
    |       └─ backend
    └─ stylesheets
        └─ spree
            └─ frontend
            └─ backend
```

This directory structure is designed to keep assets from the `solidus_frontend`
and `solidus_backend` from conflicting with each other.

Solidus also generates top-level [manifests][rails-manifests] that require all
of the Solidus-provided stylesheets and JavaScript files as well as your own
site-specific files.

To see the stock Solidus assets, you can check the contents of the
`solidus_frontend` and `solidus_backend` gems installed on your system or
[the `app/assets` contents in the Solidus GitHub repo][solidus-assets-contents].

[rails-assets-pipeline]: http://guides.rubyonrails.org/asset_pipeline.html
[rails-manifests]: http://guides.rubyonrails.org/asset_pipeline.html#manifest-files-and-directives
[solidus-assets-contents]: https://github.com/solidusio/solidus/tree/master/frontend/app/assets

## Solidus manifests

The `solidus_frontend` and `solidus_backend` gems provide [asset
manifests][rails-manifests] that bundle up all the JavaScript files and stylesheets
that they require. For example, see the `all.css` and `all.js` manifests in the
`vendor` tree:

```
vendor
└─ assets
    └─ javascripts
    |   └─ spree
    |       ├─ frontend
    |       |   └─ all.js
    |       └─ backend
    |           └─ all.js
    └─ stylesheets
        └─ spree
            ├─ frontend
            |   └─ all.css
            └─ backend
                └─ all.css
```

Your project's `vendor/assets/javascripts/spree/backend/all.js` file would show
you that your Solidus backend include jQuery and any other files that you create
in this `spree/backend` directory:

```javascript
//= require jquery
//= require rails-ujs
//= require spree/backend
//= require_tree .
```

<!-- TODO:
  Because a typical Solidus installation includes a few manifest files – and
  not all of them have the same name – it might be worthwhile to extend the
  documentation of them.
-->

## Managing application assets

We recommend using the [Rails' suggested approach to asset
organization][asset-organization], then scoping your custom files to the
`spree/frontend` or `spree/backend` subdirectories to avoid conflicts or
accidental file overrides.

For example, if you want to use the [Foundation CSS framework][foundation] in
your store's frontend, you would put the `foundation.css` file in the following
location:

```
vendor/assets/stylesheets/spree/frontend/foundation.css
```

Doing this will ensure that Foundation is scoped to the frontend and would never
affect the Solidus backend's user interface.

Then, if you wanted to override a specific style on your homepage, you might
create another file in your `app/assets` tree:

```
app/assets/stylesheets/spree/frontend/home.css
```

[asset-organization]: http://guides.rubyonrails.org/asset_pipeline.html#asset-organization
[foundation]: https://foundation.zurb.com/

## Managing your Solidus extension's assets

We recommend that all third-party extensions should adopt the same approach
as Solidus: provide manifest files with the same names and in the same
directory structure used by the `solidus_frontend` and `solidus_backend` gems.

The manifest files for third-party extensions are not included automatically in
your manifest files. You can either document how developers should add include
your extension's required assets manually or provide a [Rails
generator][rails-generators] that includes it for them.

For an example of an extension that uses a generator to install stylesheets and
migrations see the [`install_generator` for
`solidus_static_content`][solidus-static-content-install-generator].

[rails-generators]: http://guides.rubyonrails.org/generators.html
[solidus-static-content-install-generator]: https://github.com/solidusio-contrib/solidus_static_content/blob/master/lib/generators/solidus_static_content/install/install_generator.rb
