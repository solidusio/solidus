namespace 'solidus:migrations:copy_shipped_shipments_to_cartons' do
  # This copies data from shipments into cartons from previous versions of
  # Solidus.

  # Used in the migration CopyShippedShipmentsToCartons and made available as a
  # rake task to allow running it a second time after deploying the new code, in
  # case some shipment->carton data was missed between the time that the
  # migration was run and the application servers were restarted with the new
  # code.

  # This task should be safe to run multiple times.

  # We're doing these via SQL because for large stores with lots of shipments
  # and lots of inventory units this would take excessively long to do via
  # ActiveRecord one at a time. Also, these queries can take a long time for
  # large stores so we do them in batches.

  task up: :environment do
    bad_shipping_rate = Solidus::ShippingRate.
      select(:shipment_id).
      where(selected: true).
      group(:shipment_id).
      having("count(0) > 1").
      limit(1).to_a.first

    if bad_shipping_rate
      # This would end up generating multiple cartons for a single shipment
      raise(<<-TEXT.squish)
        Error: You have shipments with more than one 'selected' shipping rate,
        such as shipment #{bad_shipping_rate.shipment_id}. This code will not
        work correctly.
      TEXT
    end

    say_with_time 'generating cartons' do

      last_id = Solidus::Shipment.last.try!(:id) || 0

      in_batches(last_id: last_id) do |start_id, end_id|

        say_with_time "processing shipment #{start_id} to #{end_id}" do
          Solidus::Carton.connection.execute(<<-SQL.strip_heredoc)
            insert into solidus_cartons
              (
                number, imported_from_shipment_id, stock_location_id,
                address_id, shipping_method_id, tracking, shipped_at,
                created_at, updated_at
              )
            select
              -- create the carton number as 'C'+shipment number:
              #{db_concat("'C'", "solidus_shipments.number")}, -- number
              solidus_shipments.id, -- imported_from_shipment_id
              solidus_shipments.stock_location_id,
              solidus_shipments.address_id,
              solidus_shipping_rates.shipping_method_id,
              solidus_shipments.tracking,
              solidus_shipments.shipped_at,
              '#{Time.current.to_s(:db)}', -- created_at
              '#{Time.current.to_s(:db)}' -- updated_at
            from solidus_shipments
            left join solidus_shipping_rates
              on solidus_shipping_rates.shipment_id = solidus_shipments.id
              and solidus_shipping_rates.selected = #{Solidus::Carton.connection.quoted_true}
            left join solidus_inventory_units
              on solidus_inventory_units.shipment_id = solidus_shipments.id
              and solidus_inventory_units.carton_id is not null
            where solidus_shipments.shipped_at is not null
            -- must have at least one inventory unit
            and exists (
              select 1
              from solidus_inventory_units iu
              where iu.shipment_id = solidus_shipments.id
            )
            -- if *any* inventory units are connected to cartons then we assume
            -- the entire shipment has been either already migrated or handled
            -- by the new code
            and solidus_inventory_units.id is null
            and solidus_shipments.id >= #{start_id}
            and solidus_shipments.id <= #{end_id}
          SQL
        end
      end

    end

    say_with_time 'linking inventory units to cartons' do

      last_id = Solidus::InventoryUnit.last.try!(:id) || 0

      in_batches(last_id: last_id) do |start_id, end_id|

        say_with_time "processing inventory units #{start_id} to #{end_id}" do
          Solidus::InventoryUnit.connection.execute(<<-SQL.strip_heredoc)
            update solidus_inventory_units
            set carton_id = (
              select solidus_cartons.id
              from solidus_shipments
              inner join solidus_cartons
                on solidus_cartons.imported_from_shipment_id = solidus_shipments.id
              where solidus_shipments.id = solidus_inventory_units.shipment_id
            )
            where solidus_inventory_units.carton_id is null
            and solidus_inventory_units.shipment_id is not null
            and solidus_inventory_units.id >= #{start_id}
            and solidus_inventory_units.id <= #{end_id}
          SQL
        end
      end

    end

  end

  task down: :environment do
    last_id = Solidus::InventoryUnit.last.try!(:id) || 0

    say_with_time 'unlinking inventory units from cartons' do

      in_batches(last_id: last_id) do |start_id, end_id|
        say_with_time "processing inventory units #{start_id} to #{end_id}" do
          Solidus::InventoryUnit.connection.execute(<<-SQL.strip_heredoc)
            update solidus_inventory_units
            set carton_id = null
            where carton_id is not null
            and exists (
              select 1
              from solidus_cartons
              where solidus_cartons.id = solidus_inventory_units.carton_id
              and solidus_cartons.imported_from_shipment_id is not null
            )
            and solidus_inventory_units.id >= #{start_id}
            and solidus_inventory_units.id <= #{end_id}
          SQL
        end
      end

    end

    say_with_time "clearing carton imported_from_shipment_ids" do
      Solidus::Carton.where.not(imported_from_shipment_id: nil).delete_all
    end
  end

  def db_concat(*args)
    case Solidus::Shipment.connection.adapter_name
    when /mysql/i
      "concat(#{args.join(', ')})"
    else
      args.join(' || ')
    end
  end

  def say_with_time(message)
    say message
    ms = Benchmark.ms { yield }
    say "(#{ms.round}ms)"
  end

  def say(message)
    if Rails.env.test?
      Rails.logger.info message
    else
      puts message
    end
  end

  def in_batches(last_id:)
    start_id = 1
    batch_size = 10_000

    while start_id <= last_id
      end_id = start_id + batch_size - 1

      yield start_id, end_id

      start_id += batch_size
    end
  end

end
