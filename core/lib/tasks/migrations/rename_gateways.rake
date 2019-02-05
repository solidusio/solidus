# frozen_string_literal: true

require 'solidus/migrations/rename_gateways'

namespace 'solidus:migrations:rename_gateways' do
  task up: :environment do
    Spree::Deprecation.warn("rake solidus:migrations:rename_gateways:up has been deprecated and will be removed with Solidus 3.0.")
    count = Solidus::Migrations::RenameGateways.new.up

    unless ENV['VERBOSE'] == 'false' || !verbose
      puts "Renamed #{count} gateways into payment methods."
    end
  end

  task down: :environment do
    Spree::Deprecation.warn("rake solidus:migrations:rename_gateways:down has been deprecated and will be removed with Solidus 3.0.")
    count = Solidus::Migrations::RenameGateways.new.down

    unless ENV['VERBOSE'] == 'false' || !verbose
      puts "Renamed #{count} payment methods into gateways."
    end
  end
end
