namespace :solidus do
  namespace :migrations do
    namespace :ensure_store_on_orders do
      desc "Makes sure every order in the system has a store attached"
      task up: :environment do

        attach_store_to_all_orders
      end

      def attach_store_to_all_orders
        orders_without_store_count = Spree::Order.where(store_id: nil).count
        if orders_without_store_count == 0
          puts "Everything is good, all orders in your database have a store attached."
          return
        end

        spree_store_count = Spree::Store.count
        if spree_store_count == 0
          raise "You do not have a store set up. Please create a store instance for your installation."
        elsif spree_store_count > 1
          raise(<<-TEXT.squish)
            You have more than one store set up. We can not be sure which store to attach your
            orders to. Please attach store ids to all your orders, and run this task again
            when you're finished.
          TEXT
        end

        default_store = Spree::Store.where(default: true).first
        unless default_store
          raise "Your store is not marked as default. Please mark your one store as the default store and run this task again."
        end

        Spree::Order.where(store_id: nil).update_all(store_id: Spree::Store.default.id)
        puts "All orders updated with the default store."
      end
    end
  end
end
