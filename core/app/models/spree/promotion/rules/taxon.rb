module Spree
  class Promotion
    module Rules
      class Taxon < PromotionRule
        has_many :promotion_rule_taxons, class_name: 'Spree::PromotionRuleTaxon', foreign_key: :promotion_rule_id
        has_many :taxons, through: :promotion_rule_taxons, class_name: 'Spree::Taxon'

        MATCH_POLICIES = %w(any all none)
        preference :match_policy, default: MATCH_POLICIES.first

        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        def eligible?(order, _options = {})
          order_taxons = taxons_in_order_including_parents(order)
          if preferred_match_policy == 'all'
            unless (taxons.to_a - order_taxons).empty?
              eligibility_errors.add(:base, eligibility_error_message(:missing_taxon))
            end
          elsif preferred_match_policy == 'any'
            unless taxons.any?{ |taxon| order_taxons.include? taxon }
              eligibility_errors.add(:base, eligibility_error_message(:no_matching_taxons))
            end
          elsif preferred_match_policy == 'none'
            unless taxons.none?{ |taxon| order_taxons.include? taxon }
              eligibility_errors.add(:base, eligibility_error_message(:has_excluded_taxon))
            end
          else
            eligibility_errors.add(:base, eligibility_error_message(:software_error))
            logger.error "#{self.class.name} has unexpected match policy #{preferred_match_policy.inspect} and is not eligible. #{inspect}"
          end

          eligibility_errors.empty?
        end

        def actionable?(line_item)
          case preferred_match_policy
          when 'any', 'all'
            taxon_product_ids.include? line_item.variant.product_id
          when 'none'
            taxon_product_ids.exclude? line_item.variant.product_id
          else
            raise "unexpected match policy: #{preferred_match_policy.inspect}"
          end
        end

        def taxon_ids_string
          taxons.pluck(:id).join(',')
        end

        def taxon_ids_string=(s)
          ids = s.to_s.split(',').map(&:strip)
          self.taxons = Spree::Taxon.find(ids)
        end

        private

        # All taxons in an order
        def order_taxons(order)
          Spree::Taxon.joins(products: { variants_including_master: :line_items }).where(spree_line_items: { order_id: order.id }).distinct
        end

        # ids of taxons rules and taxons rules children
        def taxons_including_children_ids
          taxons.flat_map { |taxon| taxon.self_and_descendants.ids }
        end

        # taxons order vs taxons rules and taxons rules children
        def order_taxons_in_taxons_and_children(order)
          order_taxons(order).where(id: taxons_including_children_ids)
        end

        def taxons_in_order_including_parents(order)
          order_taxons_in_taxons_and_children(order).flat_map(&:self_and_ancestors).uniq
        end

        def taxon_product_ids
          Spree::Product.joins(:taxons).where(spree_taxons: { id: taxons.pluck(:id) }).pluck(:id).uniq
        end
      end
    end
  end
end
