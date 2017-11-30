# Overview

This guide covers how Solidus manages its JavaScript, stylesheet and image
assets and how you can extend and customize them including:

-   Understanding Solidus's use of the Rails asset pipeline
-   Managing application specific assets
-   Managing extension specific assets
-   Overriding Solidus's core assets

## Solidus's Asset Pipeline

Solidus leverages Rails' asset pipeline to allow for extension and customization of frontend and backend assets. Using asset customization techniques outlined below you can adapt all the JavaScript, stylesheets and images in Solidus to easily provide a fully custom experience.

All Solidus generated (or upgraded) applications include an `app/assets`
directory (as is standard for all Rails apps). We've taken this one
step further by subdividing each top level asset directory (images,
JavaScript files, stylesheets) into frontend and backend directories. This is
designed to keep assets from the frontend and backend from conflicting with each other.

A typical assets directory for a Solidus application will look like:

    app
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

Solidus also generates four top level manifests (all.css & all.js, see
above) that require all the core extension's and site specific
stylesheets / JavaScript files.

## How core extensions (engines) manage assets

All core engines have been updated to provide four asset manifests that
are responsible for bundling up all the JavaScript files and stylesheets
required for that engine.

For example, Solidus provides the following manifests:

    vendor
    |-- assets
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

These manifests are included by default by the
relevant all.css or all.js in the host Solidus application. For example,
`vendor/assets/javascripts/spree/backend/all.js` includes:

```ruby
    //= require jquery
    //= require jquery_ujs

    //= require spree/backend

    //= require_tree .
```

External JavaScript libraries, stylesheets and images have also be
relocated into vendor/assets (again Rails standard approach), and
all core extensions no longer have public directories.

## Managing your application's assets

Assets that customize your Solidus store should go inside the appropriate
directories inside `vendor/assets/images/spree`, `vendor/assets/javascripts/spree`,
or `vendor/assets/stylesheets/spree`. This is done so that these assets do
not interfere with other parts of your application.

## Managing your extension's assets

We're suggesting that all third party extensions should adopt the same
approach as Solidus and provide the same four (or less depending on
what the extension requires) manifest files, using the same directory
structure as outlined above.

Third party extension manifest files will not be automatically included
in the relevant all.(js|css) files so it's important to document the
manual inclusion in your extensions installation instructions or provide
a Rails generator to do so.

For an example of an extension using a generator to install assets and
migrations take a look at the [install_generator for solidus_auth_devise]( https://github.com/solidusio/solidus_auth_devise/blob/master/lib/generators/solidus/auth/install/install_generator.rb).

