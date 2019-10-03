# State Machines

Solidus uses the [`state_machines`][state-machines-gem] gem internally for
defining the state-related logic.  
While most of the e-commerces don't need to customize the default state
machines, Solidus allows providing a custom implementation for the following
models' attributes:

- `Spree::InventoryUnit`
  - [`state`][inventory-unit-sm]
- `Spree::Payment`
  - [`state`][payment-sm]
- `Spree::Reimbursement`
  - [`reimbursement_status`][reimbursement-sm]
- `Spree::ReturnAuthorization`
  - [`state`][return-authorization-sm]
- `Spree::ReturnItem`
  - [`acceptance_status`][return-item-acceptance-sm]
  - [`reception_status`][return-item-reception-sm]
- `Spree::Shipment`
  - [`state`][shipment-sm]

[inventory-unit-sm]: https://github.com/solidusio/solidus/tree/master/core/lib/spree/core/state_machines/inventory_unit.rb
[payment-sm]: https://github.com/solidusio/solidus/tree/master/core/lib/spree/core/state_machines/payment.rb
[reimbursement-sm]: https://github.com/solidusio/solidus/tree/master/core/lib/spree/core/state_machines/reimbursement.rb
[return-authorization-sm]: https://github.com/solidusio/solidus/tree/master/core/lib/spree/core/state_machines/return_authorization.rb
[return-item-acceptance-sm]: https://github.com/solidusio/solidus/tree/master/core/lib/spree/core/state_machines/return_item/acceptance_status.rb
[return-item-reception-sm]: https://github.com/solidusio/solidus/tree/master/core/lib/spree/core/state_machines/return_item/reception_status.rb
[shipment-sm]: https://github.com/solidusio/solidus/tree/master/core/lib/spree/core/state_machines/shipment.rb

### State machines customization

If you need to customize an existing state machine, create a module
containing your custom definition:

```ruby
# app/models/concerns/my_store/state_machines/return_authorization.rb

module MyStore
  module StateMachines
    module ReturnAuthorization
      extend ActiveSupport::Concern

      included do
        state_machine initial: :authorized do
          before_transition to: :canceled, do: :cancel_return_items

          event :cancel do
            transition to: :canceled, from: :authorized
          end

          event :custom_event do
            transition to: :custom_state, from: :authorized
          end
        end
      end
    end
  end
end

```

Then assign your custom module _name_ to the state machines registry:

```ruby
# config/initializers/spree.rb

Spree.config do |config|
  # Return authorization status
  config.state_machines.return_authorization = '::MyStore::StateMachines::ReturnAuthorization'

  # Other configurable state machines available:

  # Return Item reception status
  # config.state_machines.return_item_reception = '<your-custom-module-name>'

  # Return Item acceptance status
  # config.state_machines.return_item_acceptance = '<your-custom-module-name>'

  # Payment status
  # config.state_machines.payment = '<your-custom-module-name>'

  # Inventory Unit status
  # config.state_machines.inventory_unit = '<your-custom-module-name>'
end

```

This will include your custom module into `Spree::ReturnAuthorization` class
instead of the Solidus provided one.

### Using different state machines implementations

You can also completely replace [`state_machines`][state-machines-gem] with
your own implementation. Just make sure to expose the following API.

**For each event**, the [`state_machines`][state-machines-gem] gem dynamically
implements the following instance methods:

- `#<event_name>`
- `#<event_name>!`
- `#can_<event_name>?`

for example, having a state machine event named `cancel`, you'll need to
implement:

- `#cancel`
- `#cancel!`
- `#can_cancel?`

**For each state**, the following instance method is implemented:

- `#<state_name>?`

for example, having a state named `canceled`, your custom implementation should
expose:

- `#canceled?`

[state-machines-gem]: https://github.com/state-machines/state_machines
