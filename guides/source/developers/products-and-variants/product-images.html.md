# Product images

Product images belong to the `Spree::Image` model and belong to the variants of
a product. Solidus handles the creation and storage of images using
[Paperclip][paperclip-gem].

Take note of these product image properties:

- `viewable_id`: The ID for the variant that this image is linked to.
- `attachment_width` and `attachment_height`: The width and height of the
  original image that was uploaded. See the [Paperclip
  section](#paperclip-settings) of this article for more information about how
  Solidus resizes product images.
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

If you have changed your [Paperclip configuration](#paperclip-settings), make
sure that you include `noimage` images for each of image attachment keys that
you have defined. The default keys are `mini`, `small`, `product`, and `large`.

## Images for all variants

Administrators can upload images when adding or editing a product in the
[`solidus_backend`][solidus-backend]. The images can be set to be displayed
for a specific variant or for **All** variants.

If set to **All**, the `viewable_id` is set to the master variant for the
current product.

## Paperclip settings

[Paperclip][paperclip-gem] handles the creation and storage of product images.
By default, it creates several versions of each image at specific sizes.

You can check the default settings by calling the `attachment_definitions`
method on `Spree::Image` in your Rails console:

```ruby
>> Spree::Image.attachment_definitions[:attachment][:styles]
=> {:mini=>"48x48>", :small=>"400x400>", :product=>"680x680>", :large=>"1200x1200>"}
```

The default sizes can be changed in an initializer. For example, in your
`config/initializers/paperclip.rb` file. You can set new defaults like this:

```ruby
# E.g. these were the default values for Solidus up to version 2.9
Spree::Image.attachment_definitions[:attachment][:styles] = {
  mini: '48x48>',
  small: '100x100>',
  product: '240x240>',
  large: '600x600>'
}
```

### Regenerate thumbnails

If you change the default image sizes, you must regenerate the Paperclip
thumbnails by running a Rake task:

```bash
bundle exec rake paperclip:refresh:thumbnails CLASS=Spree::Image
```

[paperclip-gem]: https://github.com/thoughtbot/paperclip
[solidus-backend]: https://github.com/solidusio/solidus/tree/master/backend
[solidus-noimage]: https://github.com/solidusio/solidus/tree/master/core/app/assets/images/noimage
