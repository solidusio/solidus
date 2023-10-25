# frozen_string_literal: true

module SolidusFriendlyPromotions
  class MigrateAdjustments
    class << self
      def up
        sql = <<~SQL
          UPDATE spree_adjustments
          SET source_id = friendly_promotion_actions.id,
            source_type = 'SolidusFriendlyPromotions::PromotionAction'
            FROM spree_promotion_actions
            INNER JOIN friendly_promotion_actions ON friendly_promotion_actions.original_promotion_action_id = spree_promotion_actions.id
            WHERE spree_adjustments.source_id = spree_promotion_actions.id and spree_adjustments.source_type = 'Spree::PromotionAction'
        SQL

        execute(sql)
      end

      def down
        sql = <<~SQL
          UPDATE spree_adjustments
          SET source_id = spree_promotion_actions.id,
            source_type = 'Spree::PromotionAction'
            FROM spree_promotion_actions
            INNER JOIN friendly_promotion_actions ON friendly_promotion_actions.original_promotion_action_id = spree_promotion_actions.id
            WHERE spree_adjustments.source_id = friendly_promotion_actions.id and spree_adjustments.source_type = 'SolidusFriendlyPromotions::PromotionAction'
        SQL

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
