# Events

The `Spree::Event` module allows to fire and subscribe events inside Solidus codebase and extensions.

The module can use different adapters that actually manage events at low level, the default adapter is Rails `ActiveSupport::Notification`. Future releases may include other adapters.

Among other uses, Solidus codebase uses events in order to send confirmation emails when an order is finalized, or again to send emails when an order is refunded successfully.

Events make easy extending Solidus with custom behavior. For example, if besides the standard email you also want to send a SMS text message to the customer when a order is finalized, this pseudo-code may do the trick:

```ruby
Spree::Event.subscribe 'order_finalized' do |event|
  order = event.payload[:order]
  SmsLibrary.deliver(order, :finalized)
end
```

## Changing the adapter

The adapter can be changed using this code, for example in a initializer:

```ruby
Spree::Config.events.adapter = "Spree::EventBus.new"
```

## Subscribing to events

`Spree::Event.subscribe` allows to subscribe to a certain event. The event name is mandatory, the optional block will be executed everytime the event is fired:

```ruby
Spree::Event.subscribe 'order_finalized' do |event|
  order = event.payload[:order]
  Spree::Mailer.order_finalized(order).deliver_later
end
```

## Firing events

`Spree::Event.fire` allows to fire an event. The event name is mandatory, then both a hash of options (it will be available as the event payload) and an optional code block can be passed:

```ruby
Spree::Event.fire 'order_finalized', order: @order do
  @order.finalize!
end
```

This is an alternative way to basically have the same functionality but without the block:

```ruby
@order.finalize!
Spree::Event.fire 'order_finalized', order: @order
```

For further information, please refer to the RDOC documentation included in the `Spree::Event` module.
