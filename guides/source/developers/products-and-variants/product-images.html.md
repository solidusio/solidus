# Product images

Product images belong to the `Spree::Image` model and belong to the variants of
a product. The latest version (>= 3.0) of Solidus handles the creation and storage
of images using [Active Storage][activestorage] by default (previously
[Paperclip][paperclip-gem]).

Take note of these product image properties:

- `viewable_id`: The ID for the variant that this image is linked to.
- `attachment_width` and `attachment_height`: The width and height of the
  original image that was uploaded. See the [image settings](#image-settings)
  of this article for more information about how Solidus resizes product images.
- `position`: Sets the image's position in a list of images. For example, an
  image with the `position` of `2` would be displayed after the image with the
  `position` of `1`.
- `alt`: The alt text for an image. Administrators can add this from the
  backend.

## Fallback images

Every product image is linked to the ID of a specific `Spree::Variant`. However,
if the variant is a master variant (the variant's `is_master` property equals
`true`) this image can be displayed as a fallback for other variants without
images.

If you want to change the image that is displayed when a product has no image,
you can override Solidus's [`noimage` defaults][solidus-noimage] in your project
by creating a `app/assets/images/noimages` directory.

If you have changed your [image settings](#image-settings), make
sure that you include `noimage` images for each of image attachment keys that
you have defined. The default keys are `mini`, `small`, `product`, and `large`.

## Images for all variants

Administrators can upload images when adding or editing a product in the
[`solidus_backend`][solidus-backend]. The images can be set to be displayed
for a specific variant or for **All** variants.

If set to **All**, the `viewable_id` is set to the master variant for the
current product.

## Image settings

[Active Storage][activestorage] and [Paperclip][paperclip-gem] handle the
creation and storage of product images. By default, they create several
versions of each image at specific sizes.

You can check the default settings by inspecting the `product_image_styles`
option on `Spree::Config` in your Rails console:

```ruby
>> Spree::Config.product_image_styles
=> {:mini=>"48x48>", :small=>"400x400>", :product=>"680x680>", :large=>"1200x1200>"}
```

The default sizes can be changed using the `Spree::Config.product_image_styles`
option. For example, in your `config/initializers/spree.rb` file. You can set
new defaults like this:

```ruby
# config/initializers/spree.rb

# E.g. these were the default values for Solidus up to version 2.9
config.product_image_styles = {
  mini: '48x48>',
  small: '100x100>',
  product: '240x240>',
  large: '600x600>'
}
```

### Regenerate thumbnails

[Active Storage][activestorage] will automatically generate the sizes upon
initial request.

If you change the default image sizes and are using Paperclip, you must
regenerate the thumbnails by running a Rake task:

```bash
bundle exec rake paperclip:refresh:thumbnails CLASS=Spree::Image
```

## Using Paperclip

[Active Storage][activestorage] is the default backend for `Spree::Image`
starting with Solidus 3.0. As we don't want to force existing stores to migrate
their existing Paperclip assets, we will support the [maintained fork of
paperclip][maintained-paperclip-gem] for a while. Because of this we do not
recommend switching to Paperclip when creating a new Solidus application.

Switching to the Paperclip backend can be achieved by changing the configuration
for `Spree::Config.image_attachment_module` and
`Spree::Config.taxon_attachment_module`:

```ruby
# config/initializers/spree.rb

config.image_attachment_module = 'Spree::Image::PaperclipAttachment'
config.taxon_attachment_module = 'Spree::Taxon::PaperclipAttachment'
```

[activestorage]: https://github.com/rails/rails/tree/main/activestorage
[paperclip-gem]: https://github.com/thoughtbot/paperclip
[maintained-paperclip-gem]: https://github.com/kreeti/kt-paperclip
[solidus-backend]: https://github.com/solidusio/solidus/tree/master/backend
[solidus-noimage]: https://github.com/solidusio/solidus/tree/master/core/app/assets/images/noimage
