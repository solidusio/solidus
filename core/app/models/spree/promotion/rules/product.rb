# frozen_string_literal: true

module Spree
  class Promotion < Spree::Base
    module Rules
      # A rule to limit a promotion based on products in the order.  Can
      # require all or any of the products to be present.  Valid products
      # either come from assigned product group or are assingned directly to
      # the rule.
      class Product < PromotionRule
        has_many :product_promotion_rules, dependent: :destroy, foreign_key: :promotion_rule_id,
                                           class_name: 'Spree::ProductPromotionRule'
        has_many :products, class_name: 'Spree::Product', through: :product_promotion_rules

        MATCH_POLICIES = %w(any all none)

        validates_inclusion_of :preferred_match_policy, in: MATCH_POLICIES

        preference :match_policy, :string, default: MATCH_POLICIES.first

        # scope/association that is used to test eligibility
        def eligible_products
          products
        end

        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        def eligible?(order, _options = {})
          return true if eligible_products.empty?

          case preferred_match_policy
          when 'all'
            unless eligible_products.all? { |product| order.products.include?(product) }
              eligibility_errors.add(:base, eligibility_error_message(:missing_product), error_code: :missing_product)
            end
          when 'any'
            unless order.products.any? { |product| eligible_products.include?(product) }
              eligibility_errors.add(:base, eligibility_error_message(:no_applicable_products), error_code: :no_applicable_products)
            end
          when 'none'
            unless order.products.none? { |product| eligible_products.include?(product) }
              eligibility_errors.add(:base, eligibility_error_message(:has_excluded_product), error_code: :has_excluded_product)
            end
          else
            raise "unexpected match policy: #{preferred_match_policy.inspect}"
          end

          eligibility_errors.empty?
        end

        def actionable?(line_item)
          case preferred_match_policy
          when 'any', 'all'
            product_ids.include? line_item.variant.product_id
          when 'none'
            product_ids.exclude? line_item.variant.product_id
          else
            raise "unexpected match policy: #{preferred_match_policy.inspect}"
          end
        end

        def product_ids_string
          product_ids.join(',')
        end

        def product_ids_string=(product_ids)
          self.product_ids = product_ids.to_s.split(',').map(&:strip)
        end
      end
    end
  end
end
