# Building a custom gateway

In order to make your custom gateway available on backend list of payment
methods you need to add it to spree config list of payment methods first. That
can be achieved by adding the following code in your spree.rb for example:

```ruby
Rails.application.config.spree.payment_methods << YourCustomGateway

```
