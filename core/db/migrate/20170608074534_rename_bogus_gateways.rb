class RenameBogusGateways < ActiveRecord::Migration[5.0]
  def up
    say_with_time 'Renaming bogus gateways into payment methods' do
      Rake::Task['solidus:migrations:rename_gateways:up'].invoke
    end
  end

  def down
    say_with_time 'Renaming bogus payment methods into gateways' do
      Rake::Task['solidus:migrations:rename_gateways:down'].invoke
    end
  end
end
