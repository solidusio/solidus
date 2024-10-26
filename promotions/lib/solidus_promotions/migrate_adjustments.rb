# frozen_string_literal: true

module SolidusPromotions
  class MigrateAdjustments
    class << self
      def up
        sql = if ActiveRecord::Base.connection_db_config.adapter == "mysql2"
          <<~SQL
            UPDATE spree_adjustments
              INNER JOIN spree_promotion_actions ON spree_adjustments.source_id = spree_promotion_actions.id and spree_adjustments.source_type = 'Spree::PromotionAction'
              INNER JOIN solidus_promotions_benefits ON solidus_promotions_benefits.original_promotion_action_id = spree_promotion_actions.id
            SET source_id = solidus_promotions_benefits.id,
              source_type = 'SolidusPromotions::Benefit'
          SQL
        else
          <<~SQL
            UPDATE spree_adjustments
            SET source_id = solidus_promotions_benefits.id,
              source_type = 'SolidusPromotions::Benefit'
            FROM spree_promotion_actions
              INNER JOIN solidus_promotions_benefits ON solidus_promotions_benefits.original_promotion_action_id = spree_promotion_actions.id
            WHERE spree_adjustments.source_id = spree_promotion_actions.id and spree_adjustments.source_type = 'Spree::PromotionAction'
          SQL
        end

        execute(sql)
      end

      def down
        sql = if ActiveRecord::Base.connection_db_config.adapter == "mysql2"
          <<~SQL
            UPDATE spree_adjustments
              INNER JOIN solidus_promotions_benefits
              INNER JOIN spree_promotion_actions ON spree_adjustments.source_id = solidus_promotions_benefits.id and spree_adjustments.source_type = 'SolidusPromotions::Benefit'
            SET source_id = spree_promotion_actions.id,
              source_type = 'Spree::PromotionAction'
            WHERE solidus_promotions_benefits.original_promotion_action_id = spree_promotion_actions.id
          SQL
        else
          <<~SQL
            UPDATE spree_adjustments
            SET source_id = spree_promotion_actions.id,
                source_type = 'Spree::PromotionAction'
            FROM spree_promotion_actions
              INNER JOIN solidus_promotions_benefits ON solidus_promotions_benefits.original_promotion_action_id = spree_promotion_actions.id
            WHERE spree_adjustments.source_id = solidus_promotions_benefits.id and spree_adjustments.source_type = 'SolidusPromotions::Benefit'
          SQL
        end

        execute(sql)
      end

      private

      def execute(sql)
        Spree::Adjustment.transaction do
          ActiveRecord::Base.connection.execute(sql)
        end
      end
    end
  end
end
