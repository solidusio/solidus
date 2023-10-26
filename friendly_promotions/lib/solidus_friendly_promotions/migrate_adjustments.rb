# frozen_string_literal: true

module SolidusFriendlyPromotions
  class MigrateAdjustments
    class << self
      def up
        sql = if ActiveRecord::Base.connection_db_config.adapter == "mysql2"
          <<~SQL
            UPDATE spree_adjustments
              INNER JOIN spree_promotion_actions ON spree_adjustments.source_id = spree_promotion_actions.id and spree_adjustments.source_type = 'Spree::PromotionAction'
              INNER JOIN friendly_promotion_actions ON friendly_promotion_actions.original_promotion_action_id = spree_promotion_actions.id
            SET source_id = friendly_promotion_actions.id,
              source_type = 'SolidusFriendlyPromotions::PromotionAction'
          SQL
        else
          <<~SQL
            UPDATE spree_adjustments
            SET source_id = friendly_promotion_actions.id,
              source_type = 'SolidusFriendlyPromotions::PromotionAction'
            FROM spree_promotion_actions
              INNER JOIN friendly_promotion_actions ON friendly_promotion_actions.original_promotion_action_id = spree_promotion_actions.id
            WHERE spree_adjustments.source_id = spree_promotion_actions.id and spree_adjustments.source_type = 'Spree::PromotionAction'
          SQL
        end

        execute(sql)
      end

      def down
        sql = if ActiveRecord::Base.connection_db_config.adapter == "mysql2"
          <<~SQL
            UPDATE spree_adjustments
              INNER JOIN friendly_promotion_actions 
              INNER JOIN spree_promotion_actions ON spree_adjustments.source_id = friendly_promotion_actions.id and spree_adjustments.source_type = 'SolidusFriendlyPromotions::PromotionAction'
            SET source_id = spree_promotion_actions.id,
              source_type = 'Spree::PromotionAction'
            WHERE friendly_promotion_actions.original_promotion_action_id = spree_promotion_actions.id
          SQL
        else
          <<~SQL
            UPDATE spree_adjustments
            SET source_id = spree_promotion_actions.id,
                source_type = 'Spree::PromotionAction'
            FROM spree_promotion_actions
              INNER JOIN friendly_promotion_actions ON friendly_promotion_actions.original_promotion_action_id = spree_promotion_actions.id
            WHERE spree_adjustments.source_id = friendly_promotion_actions.id and spree_adjustments.source_type = 'SolidusFriendlyPromotions::PromotionAction'
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
