# frozen_string_literal: true

module SolidusPromotions
  class MigrateOrderPromotions
    class << self
      def up
        sql = <<~SQL
          INSERT INTO solidus_promotions_order_promotions (
            order_id,
            promotion_id,
            promotion_code_id,
            created_at,
            updated_at
          )
          SELECT
            spree_orders_promotions.order_id AS order_id,
            solidus_promotions_promotions.id AS promotion_id,
            solidus_promotions_promotion_codes.id AS promotion_code_id,
            spree_orders_promotions.created_at,
            spree_orders_promotions.updated_at
          FROM spree_orders_promotions
            INNER JOIN spree_promotions ON spree_orders_promotions.promotion_id = spree_promotions.id
            INNER JOIN solidus_promotions_promotions ON spree_promotions.id = solidus_promotions_promotions.original_promotion_id
            LEFT OUTER JOIN spree_promotion_codes ON spree_orders_promotions.promotion_code_id = spree_promotion_codes.id
            LEFT OUTER JOIN solidus_promotions_promotion_codes ON spree_promotion_codes.value = solidus_promotions_promotion_codes.value
          WHERE NOT EXISTS (
            SELECT NULL
            FROM solidus_promotions_order_promotions
            WHERE solidus_promotions_order_promotions.order_id = order_id
              AND (solidus_promotions_order_promotions.promotion_code_id = promotion_code_id OR promotion_code_id IS NULL)
              AND solidus_promotions_order_promotions.promotion_id = promotion_id
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
            solidus_promotions_order_promotions.order_id AS order_id,
            spree_promotions.id AS promotion_id,
            spree_promotion_codes.id AS promotion_code_id,
            solidus_promotions_order_promotions.created_at,
            solidus_promotions_order_promotions.updated_at
          FROM solidus_promotions_order_promotions
            INNER JOIN solidus_promotions_promotions ON solidus_promotions_order_promotions.promotion_id = solidus_promotions_promotions.id
            INNER JOIN spree_promotions ON spree_promotions.id = solidus_promotions_promotions.original_promotion_id
            LEFT OUTER JOIN solidus_promotions_promotion_codes ON solidus_promotions_order_promotions.promotion_code_id = solidus_promotions_promotion_codes.id
            LEFT OUTER JOIN spree_promotion_codes ON spree_promotion_codes.value = solidus_promotions_promotion_codes.value
          WHERE NOT EXISTS (
            SELECT NULL
            FROM spree_orders_promotions
            WHERE spree_orders_promotions.order_id = order_id
              AND (spree_orders_promotions.promotion_code_id = promotion_code_id OR promotion_code_id IS NULL)
              AND spree_orders_promotions.promotion_id = promotion_id
          );
        SQL
        ActiveRecord::Base.connection.execute(sql)

        SolidusPromotions::OrderPromotion.delete_all
      end
    end
  end
end
