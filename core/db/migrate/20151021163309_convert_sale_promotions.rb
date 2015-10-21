class ConvertSalePromotions < ActiveRecord::Migration
  def up
    sale_promotions.update_all(apply_automatically: true)
  end

  def down
    # intentionally left blank
  end

  private

  def sale_promotions
    promo_table = Spree::Promotion.arel_table
    code_table  = Spree::PromotionCode.arel_table

    promotion_code_join = promo_table.join(code_table, Arel::Nodes::OuterJoin).on(
      promo_table[:id].eq(code_table[:promotion_id])
    ).join_sources

    Spree::Promotion.includes(:promotion_rules).
      joins(promotion_code_join).
      where(
        code_table[:value].eq(nil).and(
          promo_table[:path].eq(nil)
        )
      ).distinct
  end
end
