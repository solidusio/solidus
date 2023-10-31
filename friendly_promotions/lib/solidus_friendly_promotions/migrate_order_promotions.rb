# frozen_string_literal: true

module SolidusFriendlyPromotions
  class MigrateOrderPromotions
    class << self
      def up
        sql = <<~SQL
          INSERT INTO friendly_order_promotions (
            order_id,
            promotion_id,
            promotion_code_id,
            created_at,
            updated_at
          )
          SELECT
            spree_orders_promotions.order_id AS order_id,
            friendly_promotions.id AS promotion_id,
            friendly_promotion_codes.id AS promotion_code_id,
            spree_orders_promotions.created_at,
            spree_orders_promotions.updated_at
          FROM spree_orders_promotions
            INNER JOIN spree_promotions ON spree_orders_promotions.promotion_id = spree_promotions.id
            INNER JOIN friendly_promotions ON spree_promotions.id = friendly_promotions.original_promotion_id
            LEFT OUTER JOIN spree_promotion_codes ON spree_orders_promotions.promotion_code_id = spree_promotion_codes.id
            LEFT OUTER JOIN friendly_promotion_codes ON spree_promotion_codes.value = friendly_promotion_codes.value
          WHERE NOT EXISTS (
            SELECT NULL
            FROM friendly_order_promotions
            WHERE friendly_order_promotions.order_id = order_id
              AND (friendly_order_promotions.promotion_code_id = promotion_code_id OR promotion_code_id IS NULL)
              AND friendly_order_promotions.promotion_id = promotion_id
          );
        SQL
        ActiveRecord::Base.connection.execute(sql)

        Spree::OrderPromotion.delete_all
      end

      def down
        sql = <<~SQL
          INSERT INTO spree_orders_promotions (
            order_id,
            promotion_id,
            promotion_code_id,
            created_at,
            updated_at
          )
          SELECT
            friendly_order_promotions.order_id AS order_id,
            spree_promotions.id AS promotion_id,
            spree_promotion_codes.id AS promotion_code_id,
            friendly_order_promotions.created_at,
            friendly_order_promotions.updated_at
          FROM friendly_order_promotions
            INNER JOIN friendly_promotions ON friendly_order_promotions.promotion_id = friendly_promotions.id
            INNER JOIN spree_promotions ON spree_promotions.id = friendly_promotions.original_promotion_id
            LEFT OUTER JOIN friendly_promotion_codes ON friendly_order_promotions.promotion_code_id = friendly_promotion_codes.id
            LEFT OUTER JOIN spree_promotion_codes ON spree_promotion_codes.value = friendly_promotion_codes.value
          WHERE NOT EXISTS (
            SELECT NULL
            FROM spree_orders_promotions
            WHERE spree_orders_promotions.order_id = order_id
              AND (spree_orders_promotions.promotion_code_id = promotion_code_id OR promotion_code_id IS NULL)
              AND spree_orders_promotions.promotion_id = promotion_id
          );
        SQL
        ActiveRecord::Base.connection.execute(sql)

        SolidusFriendlyPromotions::OrderPromotion.delete_all
      end
    end
  end
end
