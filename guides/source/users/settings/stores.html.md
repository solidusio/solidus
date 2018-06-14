# Stores

The **Settings > Stores** page allows you to manage some of the global settings
across all of your stores. These settings are useful if you manage multiple
stores and need distinct settings for some of your stores.

The following settings are available for each for your stores:

- **Site Name**: The customer-facing name of the current store.
- **Code**: An identifier for your store. Developers may need it if you operate
  multiple storefronts. You should not change this value before speaking with
  your store's developers.
- **SEO Title**: The content for the homepage's HTML `<title>` tag, which is
  used by search engines.
- **Meta Keywords**: A list of keywords that should be added to this product's
  metadata. These meta keywords are used by search engines.[^meta-keywords]
- **Meta Description**: The summary text that accompanies your homepage in
  search engine results.[^meta-descriptions]
- **Site URL**: The URL that customers use to access the current store.
- **Mail From Address**: The email address that should be used to send emails to
  customers and other users of your store.
- **Default Currency**: Optionally set the default currency that should be used
  throughout the current store. See the [Default currency](#default-currency)
  section before for more information.
- **Tax Country for Empty Carts**: Optionally set a tax country for empty carts.
  We recommend setting this to the country where a majority of your customers
  order from.
- **Locales Available in the Storefront**: A list of available locales[^locales]
  that customers can choose in the storefront.

## Default currency

When you set a default currency for a store, note that you need to provide
prices for each [product][products] in that currency. Any product can have
multiple prices associated with it.

<!-- TODO:
  Default currency comes up often on the Solidus Slack team. It seems to be a
  point of confusion for developers, and maybe for administrators. There is
  opportunity to provide more information about setting currencies, prices, etc.
-->

[^locales]: Locales allow your store to be displayed in multiple languages. See
  Wikipedia's [Locale][locale] article for more information. Talk to your
  developers about integrating locales into your store.
[^meta-keywords]: Meta keywords are used for SEO purposes. For more information
  about meta keywords see the article [Meta Keywords: What They Are and How They
  Work][meta-keywords] from WordStream.
[^meta-descriptions]: Meta descriptions are short descriptions that accompany a
  link to your page in search engine results pages (SERPs). While each search
  engine works differently, Google truncates meta descriptions after 300
  characters. For more information, see the [Meta Description][meta-description]
  article on Moz.com.

[locale]: https://en.wikipedia.org/wiki/Locale_(computer_software)
[meta-keywords]: https://www.wordstream.com/meta-keyword
[meta-description]: https://moz.com/learn/seo/meta-description
