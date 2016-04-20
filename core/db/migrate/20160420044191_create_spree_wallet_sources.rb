class CreateSpreeWalletSources < ActiveRecord::Migration[4.2]
  def change
    create_table :spree_wallet_sources do |t|
      t.references(
        :user,
        foreign_key: { to_table: Spree.user_class.table_name },
        index: true,
        null: false,
      )
      t.references :source, polymorphic: true, null: false
      t.boolean :default, default: false, null: false

      t.timestamps null: false
    end

    add_index(
      :spree_wallet_sources,
      [:user_id, :source_id, :source_type],
      unique: true,
      name: 'index_spree_wallet_sources_on_source_and_user',
    )
  end
end
