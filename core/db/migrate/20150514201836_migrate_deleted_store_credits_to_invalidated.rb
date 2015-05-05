class MigrateDeletedStoreCreditsToInvalidated < ActiveRecord::Migration
  def up
    Spree::StoreCredit.only_deleted.find_each do |store_credit|
      say "Marking deleted store credit #{store_credit.id} for #{store_credit.user.try(:email)} as invalidated"
      deleted_at = store_credit.deleted_at
      store_credit.update_attributes!(deleted_at: nil, invalidated_at: deleted_at)
    end
  end

  def down
    # intentionally blank
  end
end
