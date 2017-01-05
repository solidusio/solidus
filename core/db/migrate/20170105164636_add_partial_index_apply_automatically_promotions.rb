class AddPartialIndexApplyAutomaticallyPromotions < ActiveRecord::Migration[5.0]
  def change
    condition = "apply_automatically = #{connection.quoted_true}"
    add_index(
      :spree_promotions,
      :apply_automatically,
      where: condition,
      name: "idx_apply_automatically_promotions",
    )
  end
end
