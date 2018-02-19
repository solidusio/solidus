# frozen_string_literal: true

class RenameBogusGateways < ActiveRecord::Migration[5.0]
  def up
    require 'solidus/migrations/rename_gateways'
    say_with_time 'Renaming bogus gateways into payment methods' do
      Solidus::Migrations::RenameGateways.new.up
    end
  end

  def down
    require 'solidus/migrations/rename_gateways'
    say_with_time 'Renaming bogus payment methods into gateways' do
      Solidus::Migrations::RenameGateways.new.down
    end
  end
end
