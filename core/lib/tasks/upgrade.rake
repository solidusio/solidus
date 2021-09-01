# frozen_string_literal: true

namespace :solidus do
  namespace :upgrade do
    task three_point_zero: [
        'railties:install:migrations',
        'db:migrate'
      ] do
      puts "Your Solidus install is ready for Solidus 3.0"
    end

    desc "Upgrade Solidus to version 3.0"
    task three_point_zero: [
        'solidus:migrations:delete_prices_with_nil_amount:up',
      ] do
      puts "Your Solidus install is ready for Solidus 3.0"
    end
  end

  desc "Upgrade to the current Solidus version"
  task upgrade: 'upgrade:three_point_zero'
end
