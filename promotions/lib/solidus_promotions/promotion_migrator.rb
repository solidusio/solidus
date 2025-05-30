# frozen_string_literal: true

module SolidusPromotions
  class PromotionMigrator
    PROMOTION_IGNORED_ATTRIBUTES = ["id", "type", "promotion_category_id", "promotion_id"]

    attr_reader :promotion_map

    def initialize(promotion_map)
      @promotion_map = promotion_map
    end

    def call
      SolidusPromotions::PromotionCategory.destroy_all
      Spree::PromotionCategory.all.find_each do |promotion_category|
        SolidusPromotions::PromotionCategory.create!(promotion_category.attributes.except("id"))
      end

      SolidusPromotions::Promotion.destroy_all
      Spree::Promotion.all.find_each do |promotion|
        new_promotion = copy_promotion(promotion)
        if promotion.promotion_category&.name.present?
          new_promotion.category = SolidusPromotions::PromotionCategory.find_by(
            name: promotion.promotion_category.name
          )
        end
        new_promotion.benefits = promotion.actions.flat_map do |old_promotion_action|
          generate_new_benefits(old_promotion_action)&.tap do |new_promotion_action|
            new_promotion_action.original_promotion_action = old_promotion_action
            new_promotion_action.conditions = promotion.rules.flat_map do |old_promotion_rule|
              generate_new_promotion_conditions(old_promotion_rule)
            end
          end
        end.compact
        new_promotion.save!
        copy_promotion_code_batches(new_promotion)
        copy_promotion_codes(new_promotion)
      end
    end

    private

    def copy_promotion_code_batches(new_promotion)
      sql = <<~SQL
        INSERT INTO solidus_promotions_promotion_code_batches (promotion_id, base_code, number_of_codes, email, error, state, created_at, updated_at, join_characters)
        SELECT solidus_promotions_promotions.id AS promotion_id, base_code, number_of_codes, email, error, state, spree_promotion_code_batches.created_at, spree_promotion_code_batches.updated_at, join_characters
        FROM spree_promotion_code_batches
        INNER JOIN spree_promotions ON spree_promotion_code_batches.promotion_id = spree_promotions.id
        INNER JOIN solidus_promotions_promotions ON spree_promotions.id = solidus_promotions_promotions.original_promotion_id
        WHERE spree_promotion_code_batches.promotion_id = #{new_promotion.original_promotion_id};
      SQL
      SolidusPromotions::PromotionCodeBatch.connection.execute(sql)
    end

    def copy_promotion_codes(new_promotion)
      sql = <<~SQL
        INSERT INTO solidus_promotions_promotion_codes (promotion_id, promotion_code_batch_id, value, created_at, updated_at)
        SELECT solidus_promotions_promotions.id AS promotion_id, solidus_promotions_promotion_code_batches.id AS promotion_code_batch_id, value, spree_promotion_codes.created_at, spree_promotion_codes.updated_at
        FROM spree_promotion_codes
        LEFT OUTER JOIN spree_promotion_code_batches ON spree_promotion_code_batches.id = spree_promotion_codes.promotion_code_batch_id
        LEFT OUTER JOIN solidus_promotions_promotion_code_batches ON solidus_promotions_promotion_code_batches.base_code = spree_promotion_code_batches.base_code
        INNER JOIN spree_promotions ON spree_promotion_codes.promotion_id = spree_promotions.id
        INNER JOIN solidus_promotions_promotions ON spree_promotions.id = solidus_promotions_promotions.original_promotion_id
        WHERE spree_promotion_codes.promotion_id = #{new_promotion.original_promotion_id};
      SQL
      SolidusPromotions::PromotionCode.connection.execute(sql)
    end

    def copy_promotion(old_promotion)
      SolidusPromotions::Promotion.new(
        old_promotion.attributes.except(*PROMOTION_IGNORED_ATTRIBUTES).merge(
          customer_label: old_promotion.name,
          original_promotion: old_promotion
        )
      )
    end

    def generate_new_benefits(old_promotion_action)
      promo_action_config = promotion_map[:actions][old_promotion_action.class]
      if promo_action_config.nil?
        Rails.logger.info("#{old_promotion_action.class} is not supported")
        return nil
      end
      promo_action_config.call(old_promotion_action)
    end

    def generate_new_promotion_conditions(old_promotion_rule)
      new_promo_condition_class = promotion_map[:conditions][old_promotion_rule.class]
      if new_promo_condition_class.nil?
        Rails.logger.info("#{old_promotion_rule.class} is not supported")
        []
      elsif new_promo_condition_class.respond_to?(:call)
        new_promo_condition_class.call(old_promotion_rule)
      else
        new_condition = new_promo_condition_class.new(old_promotion_rule.attributes.except(*PROMOTION_IGNORED_ATTRIBUTES))
        new_condition.preload_relations.each do |relation|
          new_condition.send(:"#{relation}=", old_promotion_rule.send(relation))
        end
        [new_condition]
      end
    end
  end
end
