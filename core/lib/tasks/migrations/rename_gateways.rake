# frozen_string_literal: true

require 'solidus/migrations/rename_gateways'

namespace 'solidus:migrations:rename_gateways' do
  task up: :environment do
    count = Solidus::Migrations::RenameGateways.new.up

    unless ENV['VERBOSE'] == 'false' || !verbose
      puts "Renamed #{count} gateways into payment methods."
    end
  end

  task down: :environment do
    count = Solidus::Migrations::RenameGateways.new.down

    unless ENV['VERBOSE'] == 'false' || !verbose
      puts "Renamed #{count} payment methods into gateways."
    end
  end
end
