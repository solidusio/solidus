class AddOriginalPromotionIds < ActiveRecord::Migration[7.0]
  def change
    add_reference :friendly_promotions, :original_promotion, type: :integer, index: { name: :index_original_promotion_id }, foreign_key: { to_table: :spree_promotions }
    add_reference :friendly_promotion_actions, :original_promotion_action, type: :integer, index: { name: :index_original_promotion_action_id }, foreign_key: { to_table: :spree_promotion_actions }
  end
end
