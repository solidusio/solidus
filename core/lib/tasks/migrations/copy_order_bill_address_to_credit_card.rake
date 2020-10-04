# frozen_string_literal: true

namespace 'spree:migrations:copy_order_bill_address_to_credit_card' do
  # This copies the billing address from the order associated with a
  # credit card's most recent payment to the credit card.

  # Used in the migration CopyOrderBillAddressToCreditCard and made available as a
  # rake task to allow running it a second time after deploying the new code, in
  # case some order->credit card data was missed between the time that the
  # migration was run and the application servers were restarted with the new
  # code.

  # This task should be safe to run multiple times.

  task up: :environment do
    Spree::Deprecation.warn("rake spree:migrations:copy_order_bill_address_to_credit_card:up has been deprecated and will be removed with Solidus 3.0.")

    if Spree::CreditCard.connection.adapter_name =~ /postgres/i
      postgres_copy
    else
      ruby_copy
    end
  end

  task down: :environment do
    Spree::Deprecation.warn("rake spree:migrations:copy_order_bill_address_to_credit_card:down has been deprecated and will be removed with Solidus 3.0.")

    Spree::CreditCard.update_all(address_id: nil)
  end

  def ruby_copy
    scope = Spree::CreditCard.where(address_id: nil).includes(payments: :order)

    scope.find_each(batch_size: 500) do |cc|
      # remove payments that lack a bill address
      payments = cc.payments.select { |p| p.order.bill_address_id }

      payment = payments.sort_by do |p|
        [
          %w(failed invalid).include?(p.state) ? 0 : 1, # prioritize valid payments
          p.created_at, # prioritize more recent payments
        ]
      end.last

      next if payment.nil?

      cc.update_column(:address_id, payment.order.bill_address_id)
      puts "Successfully associated billing address (#{payment.order.bill_address_id}) with credit card (#{cc.id})"
    end
  end

  # This was 20x faster for us but the syntax is postgres-specific. I'm sure
  # there are equivalent versions for other DBs if someone wants to write them.
  # I took a quick stab at crafting a cross-db compatible version but it was
  # slow.
  def postgres_copy
    batch_size = 10_000

    current_start_id = 1

    while current_start_id <= last_credit_card_id
      current_end_id = current_start_id + batch_size
      puts "updating #{current_start_id} to #{current_end_id}"

      # first try to find a valid payment for each credit card
      Spree::CreditCard.connection.execute(
        postgres_sql(
          start_id: current_start_id,
          end_id: current_end_id,
          payment_state: "not in ('failed', 'invalid')"
        )
      )

      # fall back to using invalid payments for each credit card
      Spree::CreditCard.connection.execute(
        postgres_sql(
          start_id: current_start_id,
          end_id: current_end_id,
          payment_state: "in ('failed', 'invalid')"
        )
      )

      current_start_id += batch_size
    end
  end

  def postgres_sql(start_id:, end_id:, payment_state:)
    <<-SQL
      update spree_credit_cards c
      set address_id = o.bill_address_id
      from spree_payments p
      inner join spree_orders o
        on  o.id = p.order_id
        and o.bill_address_id is not null
      left join (
        select p2.*
        from spree_payments p2
        inner join spree_orders o2
          on  o2.id = p2.order_id
          and o2.bill_address_id is not null
      ) more_recent_payment
        on  more_recent_payment.source_id = p.source_id
        and more_recent_payment.source_type = 'Spree::CreditCard'
        and more_recent_payment.created_at > p.created_at
        and more_recent_payment.state #{payment_state}
      where c.address_id is null
        and p.source_id = c.id
        and p.source_type = 'Spree::CreditCard'
        and p.state #{payment_state}
        and more_recent_payment.id is null
        and o.bill_address_id is not null
        and c.id between #{start_id} and #{end_id}
    SQL
  end

  def last_credit_card_id
    Spree::CreditCard.last.try!(:id) || 0
  end
end
