# frozen_string_literal: true

namespace :solidus do
  namespace :migrations do
    namespace :delete_prices_with_nil_amount do
      task up: :environment do
        print "Deleting prices wich amount attribute is nil ... "
        Spree::Price.where(amount: nil).delete_all
        puts "Success"
      end
    end
  end
end
