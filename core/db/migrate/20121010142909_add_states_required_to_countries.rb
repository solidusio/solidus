class AddStatesRequiredToCountries < ActiveRecord::Migration
  def change
    add_column :solidus_countries, :states_required, :boolean,:default => true
  end
end
