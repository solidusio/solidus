class RemoveCreditCardAddressId < ActiveRecord::Migration
  def change
    # This hasn't been accessible for a long time:
    # https://github.com/bonobos/spree/commit/0b58afc#diff-b3d9a7a18a30a5fb3372cfcf3f925a3dL4
    remove_column :spree_credit_cards, :address_id, :integer
  end
end
