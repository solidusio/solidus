# Integrate Google Analytics into Solidus

This guide explains how to set up Google Analytics Enhanced Ecommerce with gtag.js
in Solidus. Please note that the instructions below assume that all Solidus views have
been copied in the host application, as described in the [storefront
customization guide][storefront-customization-guide].


Copy/paste the following code at `app/views/layouts/spree_application.html.rb`,
immediately after the `<head>` tag.
Replace `GA_MEASUREMENT_ID` with the ID of the Google Analytics property to which
you want to send data.

```html
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'GA_MEASUREMENT_ID');

  <%= yield :gtag %>
</script>
```

This will send a page view event to your Google Analytics account for each page visited
by your customers.

To also send information about completed orders to Google Analytics, add the following
code at `app/views/spree/orders/show.html.erb`:

```erb
<% if order_just_completed?(@order) %>
  <% content_for :gtag do %>
    <% gtag_purchase_items = [] %>
    <% order.line_items.each do |line_item| %>
      <% gtag_purchase_items.push({
        'name': line_item.variant.name,
        'id': line_item.variant.sku,
        'price': line_item.total,
        'variant': line_item.variant.options_text,
        'quantity': line_item.quantity
        }) %>
    <% end %>

    gtag('event', 'purchase', {
      "transaction_id": '<%= order.number %>',
      "affiliation": '<%= current_store.name %>',
      "value": '<%= order.total %>',
      "currency": '<%= order.currency %>',
      "tax": '<%= order.tax_total %>',
      "shipping": '<%= order.ship_total %>',
      "items": <%= raw gtag_purchase_items.to_json %>
    });
  <% end %>
<% end %>
```

Please, use [Enhanced ecommerce with gtag.js][gtag-documentation] as reference if you want to change
information sent or you need to send other events to Google Analytics.

[storefront-customization-guide]: ../customizations/customizing-storefront.html
[gtag-documentation]: https://developers.google.com/analytics/devguides/collection/gtagjs/enhanced-ecommerce

