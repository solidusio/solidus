# Overview

Promotions within Spree are used to provide discounts to orders, as well as to
add potential additional items at no extra cost. Promotions are one of the most
complex areas within Spree, as there are a large number of moving parts to
consider. Although this guide will explain Promotions from a developer's
perspective, if you are new to this area you can learn a lot from the Admin >
Promotions tab where you can set up new Promotions, edit rules & actions, etc. 

Promotions can be activated in three different ways:

* When a user adds a product to their cart
* When a user enters a coupon code during the checkout process
* When a user visits a page within the Spree store

Promotions for these individual ways are activated through their corresponding
`PromotionHandler` class, once they've been checked for eligibility.

Promotions relate to two other main components: `actions` and `rules`. When a
promotion is activated, the actions for the promotion are performed, passing in
the payload from the `fire_event` call that triggered the activator becoming
active. Rules are used to determine if a promotion meets certain criteria in
order to be applicable. (In Spree 2.1 and prior, you need to explicitly
associate a Promotion to an event like spree.order.contents_changed,
spree.order.contents_changed, spree.checkout.coupon_code_added, etc. As of Spree
2.2, this is no longer necessary and the event_name column has been dropped.)

In some special cases where a promotion has a `code` or a `path` configured for
it, the promotion will only be activated if the payload's code or path match the
promotion's. The `code` attribute is used for promotion codes, where a user must
enter a code to receive the promotion, and the `path` attribute is used to apply
a promotion once a user has visited a specific path.

!!!
Path-based promotions will only work when the `Spree::PromotionHandler::Page`
class is used, as in `Spree::ContentController` from `spree_frontend`.
!!!

A promotion may also have a `usage_limit` attribute set, which restricts how
many times the promotion can be used.

