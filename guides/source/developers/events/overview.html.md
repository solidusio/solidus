# Events

The `Spree::Event` module allows to fire and subscribe events inside the
Solidus codebase and extensions.

The module can use different adapters that actually manage events at a low
level, the default adapter is Rails `ActiveSupport::Notification`. Future
releases may include other adapters.

Among other uses, the Solidus codebase uses events in order to send
confirmation emails when an order is finalized, or again to send emails
when an order is refunded successfully.

Currently, the events fired by default in Solidus are:
* `order_finalized`
* `order_recalculated`
* `reimbursement_reimbursed`
* `reimbursement_errored`

Events make extending Solidus with custom behavior easy. For example,
if besides the standard email you also want to send a SMS text message to
the customer when a order is finalized, this pseudo-code may do the trick:

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

`Spree::Event.subscribe` allows to subscribe to a certain event. The event
name is mandatory, the optional block will be executed every time the event
is fired:

```ruby
Spree::Event.subscribe 'order_finalized' do |event|
  order = event.payload[:order]
  Spree::Mailer.order_finalized(order).deliver_later
end
```

When using the default event adapter it's possible to subscribe to multiple
events using a regexp:

```ruby
Spree::Event.subscribe /.*\.spree$/ do |event|
  puts "Event with name `#{event.name}` was just fired!"
end
```

Please note that, unless you add explicitly the `.spree` suffix namespace,
you will register to all ActiveSupportNotifications, including Rails internal
ones.

Another way to subscribe to events is creating a "subscriber" module that
includes the `Spree::Event::Subscriber` module. For example:

```ruby
# app/subscribers/spree/sms_subscriber.rb

module Spree
  module SmsSubscriber
    include Spree::Event::Subscriber

    event_action :order_finalized
    event_action :send_reimbursement_sms, event_name: :reimbursement_reimbursed

    def order_finalized(event)
      order = event.payload[:order]
      SmsLibrary.deliver(order, :finalized)
    end

    def send_reimbursement_sms(event)
      reimbursement = event.payload[:reimbursement]
      order = reimbursement.order
      SmsLibrary.deliver(order, :reimbursed)
    end
  end
end
```

The `Spree::Event::Subscriber` module provides a simple interface that
allows executing code when a specific event is fired. The `event_action`
method allows to map a method of the subscriber module to an event that
happens in the system. If the `event_name` argument is not specified,
the event name and the method name should match.

These subscribers modules are loaded with the rest of your application but
you need to manually subscribe to them.

For example, you could subscribe to them programmatically with something like:

```ruby
if defined?(SmsLibrary)
  Spree::SmsSubscriber.subscribe!
end
```

## Firing events

`Spree::Event.fire` allows you to fire an event. The event name is mandatory,
then both a hash of options (it will be available as the event payload)
and an optional code block can be passed:

```ruby
Spree::Event.fire 'order_finalized', order: @order do
  @order.finalize!
end
```

This is an alternative way to basically have the same functionality but
without the block:

```ruby
@order.finalize!
Spree::Event.fire 'order_finalized', order: @order
```

For further information, please refer to the RDOC documentation included in
the `Spree::Event` module.
