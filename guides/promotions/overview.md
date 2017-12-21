# Overview

Promotions within Spree are used to provide discounts to orders, as well as to
add potential additional items at no extra cost. Promotions are one of the most
complex areas within Spree, as there are a large number of moving parts to
consider. Although this guide will explain Promotions from a developer's
perspective, if you are new to this area you can learn a lot from the Admin >
Promotions tab where you can set up new Promotions, edit rules & actions, etc. 

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

