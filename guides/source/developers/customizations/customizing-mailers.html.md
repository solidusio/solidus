# Mailer Customizations

## Overview

Solidus has built-in transactional emails that notify customers of various events
associated with their order. For example, the following actions can trigger an email:

* Completing order checkout
* Shipping an order
* Cancelling an order

Solidus has built-in emails for all of the above scenarios and more. However,
given that the default Solidus email templates are intended to be very plain,
you will likely wish to customize them for your store. You may also want to add
new emails, such as a welcome email when a customer creates a new account, an
abandoned cart email when a customer leaves their cart without checking out,
or a notification that a customer's credit cart has expired if your store
uses recurring subscriptions. All of these are possible because Solidus uses
Rails' built-in Action Mailer to handle sending emails.

## A Brief Intro to Action Mailer

Solidus emails use [Action Mailer][Action Mailer], which is built into Rails.
Therefore, most concepts and customizations that apply to emails in Rails also
apply to Solidus. Reviewing the [Rails Action Mailer Documentation][Action Mailer]
will give you some good ideas about how transactional emails can be customized
in Solidus.

[Action Mailer]: https://guides.rubyonrails.org/action_mailer_basics.html

Action Mailer emails have two parts:

1. A view or layout where you can compose and style the email. This could be
  an `html.erb` file, or a `.txt.erb` file for text-only emails. You can also
  configure Action Mailer to parse different templating languages like HAML or
  MJML if you prefer to use those. See
  [here](https://guides.rubyonrails.org/v2.3.8/action_mailer_basics.html#configure-action-mailer-to-recognize-haml-templates)
  for information on how you can configure Action Mailer to recognize HAML
  templates, for example.
2. A mailer, which behaves very similar to a Rails controller. Like a
   controller, customizing the mailer will let you determine what information
   is available in your email's view.

## Where to Find Mailers in Solidus

The core default mailers can be found in [/core/app/mailers/spree][/core/app/mailers/spree].
Some of the more commonly-used files are as follows:

- `base_mailer.rb`, which is inherited by the other core Solidus Mailers, and
  contains some basic information about the behavior of your emails.
- `carton_mailer.rb`, for shipment notification emails.
- `order_mailer.rb`, for order confirmation emails.
- `reimbursement_mailer.rb`, for return and refund notifictaion emails.

[/core/app/mailers/spree]: https://github.com/solidusio/solidus/tree/master/core/app/mailers/spree

## Where to Find Email Views in Solidus

The core email views for Solidus can be found in [/core/app/views/spree/][/core/app/views/spree/].
Here you will find some folders with names that correspond to the above
mailers:`/carton_mailer/` and `/order_mailer/`, for example.

[/core/app/views/spree/]: https://github.com/solidusio/solidus/tree/master/core/app/views/spree

Each folder contains an `html.erb` view file that can be styled, and a `txt.erb`
file, which will be used by text-only email clients. Even if you are only planning
on sending heavily-styled emails it is important to include a text-only email
for accessibility purposes.

## How to Customize Mailers

As with other types of views, the easiest way to begin customizing your mailer is
to copy the original file from Solidus to the same path in your application.
For example, if you want to override `order_mailer.rb`, just copy the contents
of [core/app/mailers/spree/order_mailer.rb][core/app/mailers/spree/order_mailer.rb]
into your application at `/[your_store]/app/mailers/spree/order_mailer.rb`. Now
you can edit the order mailer as you like. If, for example, you wish for Rails
to reconize an alternative template filetype for your order emails, you could
add that logic here.

[core/app/mailers/spree/order_mailer.rb]: https://github.com/solidusio/solidus/tree/master/core/app/mailers/spree/order_mailer.rb

## How to Customize Email Views

Solidus email views are also located in `/core/`, so to create or override email
views, copy the corresponding directory over to your application. Using
`order_mailer.rb` as an example again, just copy the directory
[/core/app/views/spree/order_mailer/][core/app/views/spree/order_mailer] into
your app at `/[your_store]/app/views/spree/order_mailer/`. Both the `.erb` and
`.txt` files are located within the directory, and can be customized as you like.

[core/app/views/spree/order_mailer/]: https://github.com/solidusio/solidus/tree/master/core/app/views/spree/order_mailer
