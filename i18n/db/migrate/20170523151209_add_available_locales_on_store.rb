class AddAvailableLocalesOnStore < SolidusSupport::Migration[4.2]
  def change
    add_column :spree_stores, :preferences, :text

    reversible do |dir|
      dir.up do
        Spree::Store.reset_column_information
        Spree::Store.all.each do |store|
          store.update_attributes(preferred_available_locales: SolidusI18n::Config.available_locales)
        end
      end
    end
  end
end
