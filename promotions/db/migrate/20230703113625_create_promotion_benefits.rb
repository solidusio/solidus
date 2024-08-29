class CreatePromotionBenefits < ActiveRecord::Migration[7.0]
  def change
    promotion_action_foreign_key = table_exists?(:spree_promotion_actions) ? {to_table: :spree_promotion_actions} : false

    create_table :solidus_promotions_benefits do |t|
      t.references :promotion, index: true, null: false, foreign_key: {to_table: :solidus_promotions_promotions}
      t.string :type
      t.text :preferences
      t.references :original_promotion_action, type: :integer, index: {name: :index_original_promotion_action_id}, foreign_key: promotion_action_foreign_key
      t.index [:id, :type], name: :index_solidus_promotions_benefits_on_id_and_type

      t.timestamps
    end
  end
end
