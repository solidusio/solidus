# Migrate from Paperclip to ActiveStorage

## Gotchas

- Load order, the spree initializer must be loaded first, use `01_spree.rb` or similar alphabetization
- A catch-all route can prevent disk service from working
- Until [rails/rails#34581](https://github.com/rails/rails/pull/34581) is merged there's no reliable way to have cachable, non-expiring, public URLs, using the ActiveStorage adapter will generate URLs that will expire (by default) in 5 minutes
- Application code can raise errors like `Can’t resolve image into URL: undefined method 'attachment_url’ for #<#<Class:0x00007f84c22bfc70>:0x00007f84c22bdc68>` around code like `<%= link_to image_tag(line_item.product.display_image.attachment, itemprop: "image"), spree.product_path(line_item.product) %>`; this is solvable changing it to `<%= link_to image_tag(line_item.product.display_image.url, itemprop: "image"), spree.product_path(line_item.product) %>`
