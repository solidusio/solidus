class AddOriginalPromotionIds < ActiveRecord::Migration[7.0]
  def change
    promotion_foreign_key = table_exists?(:spree_promotions) ? {to_table: :spree_promotions} : false
    promotion_action_foreign_key = table_exists?(:spree_promotion_actions) ? {to_table: :spree_promotion_actions} : false
    add_reference :friendly_promotions, :original_promotion, type: :integer, index: {name: :index_original_promotion_id}, foreign_key: promotion_foreign_key
    add_reference :friendly_promotion_actions, :original_promotion_action, type: :integer, index: {name: :index_original_promotion_action_id}, foreign_key: promotion_action_foreign_key
  end
end
