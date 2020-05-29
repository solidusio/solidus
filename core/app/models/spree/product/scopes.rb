# frozen_string_literal: true

module Spree
  class Product < Spree::Base
    module Scopes
      def self.prepended(base)
        base.class_eval do
          cattr_accessor :search_scopes do
            []
          end

          def self.add_search_scope(name, &block)
            singleton_class.send(:define_method, name.to_sym, &block)
            search_scopes << name.to_sym
          end

          def self.property_conditions(property)
            properties = Property.table_name
            case property
            when String   then { "#{properties}.name" => property }
            when Property then { "#{properties}.id" => property.id }
            else { "#{properties}.id" => property.to_i }
            end
          end

          scope :ascend_by_updated_at, -> { order(updated_at: :asc) }
          scope :descend_by_updated_at, -> { order(updated_at: :desc) }
          scope :ascend_by_name, -> { order(name: :asc) }
          scope :descend_by_name, -> { order(name: :desc) }

          add_search_scope :ascend_by_master_price do
            joins(master: :default_price).select('spree_products.* , spree_prices.amount')
                                         .order(Spree::Price.arel_table[:amount].asc)
          end

          add_search_scope :descend_by_master_price do
            joins(master: :default_price).select('spree_products.* , spree_prices.amount')
                                         .order(Spree::Price.arel_table[:amount].desc)
          end

          add_search_scope :price_between do |low, high|
            joins(master: :default_price).where(Price.table_name => { amount: low..high })
          end

          add_search_scope :master_price_lte do |price|
            joins(master: :default_price).where("#{price_table_name}.amount <= ?", price)
          end

          add_search_scope :master_price_gte do |price|
            joins(master: :default_price).where("#{price_table_name}.amount >= ?", price)
          end

          # This scope selects products in taxon AND all its descendants
          # If you need products only within one taxon use
          #
          #   Spree::Product.joins(:taxons).where(Taxon.table_name => { id: taxon.id })
          #
          # If you're using count on the result of this scope, you must use the
          # `:distinct` option as well:
          #
          #   Spree::Product.in_taxon(taxon).count(distinct: true)
          #
          # This is so that the count query is distinct'd:
          #
          #   SELECT COUNT(DISTINCT "spree_products"."id") ...
          #
          #   vs.
          #
          #   SELECT COUNT(*) ...
          add_search_scope :in_taxon do |taxon|
            includes(:classifications)
              .where('spree_products_taxons.taxon_id' => taxon.self_and_descendants.pluck(:id))
              .select(Spree::Classification.arel_table[:position])
              .order(Spree::Classification.arel_table[:position].asc)
          end

          # This scope selects products in all taxons AND all its descendants
          # If you need products only within one taxon use
          #
          #   Spree::Product.taxons_id_eq([x,y])
          add_search_scope :in_taxons do |*taxons|
            taxons = get_taxons(taxons)
            taxons.first ? prepare_taxon_conditions(taxons) : where(nil)
          end

          # a scope that finds all products having property specified by name, object or id
          add_search_scope :with_property do |property|
            joins(:properties).where(property_conditions(property))
          end

          # a simple test for product with a certain property-value pairing
          # note that it can test for properties with NULL values, but not for absent values
          add_search_scope :with_property_value do |property, value|
            joins(:properties)
              .where("#{Spree::ProductProperty.table_name}.value = ?", value)
              .where(property_conditions(property))
          end

          add_search_scope :with_option do |option|
            option_types = Spree::OptionType.table_name
            conditions = case option
                         when String     then { "#{option_types}.name" => option }
                         when OptionType then { "#{option_types}.id" => option.id }
                         else { "#{option_types}.id" => option.to_i }
            end

            joins(:option_types).where(conditions)
          end

          add_search_scope :with_option_value do |option, value|
            option_values = Spree::OptionValue.table_name
            option_type_id = case option
                             when String then Spree::OptionType.find_by(name: option) || option.to_i
                             when Spree::OptionType then option.id
                             else option.to_i
            end

            conditions = "#{option_values}.name = ? AND #{option_values}.option_type_id = ?", value, option_type_id
            group('spree_products.id').joins(variants_including_master: :option_values).where(conditions)
          end

          # Finds all products which have either:
          # 1) have an option value with the name matching the one given
          # 2) have a product property with a value matching the one given
          add_search_scope :with do |value|
            includes(variants_including_master: :option_values).
              includes(:product_properties).
              where("#{Spree::OptionValue.table_name}.name = ? OR #{Spree::ProductProperty.table_name}.value = ?", value, value)
          end

          # Finds all products that have a name containing the given words.
          add_search_scope :in_name do |words|
            like_any([:name], prepare_words(words))
          end

          # Finds all products that have a name or meta_keywords containing the given words.
          add_search_scope :in_name_or_keywords do |words|
            like_any([:name, :meta_keywords], prepare_words(words))
          end

          # Finds all products that have a name, description, meta_description or meta_keywords containing the given keywords.
          add_search_scope :in_name_or_description do |words|
            like_any([:name, :description, :meta_description, :meta_keywords], prepare_words(words))
          end

          # Finds all products that have the ids matching the given collection of ids.
          # Alternatively, you could use find(collection_of_ids), but that would raise an exception if one product couldn't be found
          add_search_scope :with_ids do |*ids|
            where(id: ids)
          end

          # Sorts products from most popular (popularity is extracted from how many
          # times use has put product in cart, not completed orders)
          #
          # there is alternative faster and more elegant solution, it has small drawback though,
          # it doesn stack with other scopes :/
          #
          # joins: "LEFT OUTER JOIN (SELECT line_items.variant_id as vid, COUNT(*) as cnt FROM line_items GROUP BY line_items.variant_id) AS popularity_count ON variants.id = vid",
          # order: 'COALESCE(cnt, 0) DESC'
          add_search_scope :descend_by_popularity do
            joins(:master).
              order(%{
           COALESCE((
             SELECT
               COUNT(#{Spree::LineItem.quoted_table_name}.id)
             FROM
               #{Spree::LineItem.quoted_table_name}
             JOIN
               #{Spree::Variant.quoted_table_name} AS popular_variants
             ON
               popular_variants.id = #{Spree::LineItem.quoted_table_name}.variant_id
             WHERE
               popular_variants.product_id = #{Spree::Product.quoted_table_name}.id
           ), 0) DESC
        })
          end

          add_search_scope :not_deleted do
            where("#{Spree::Product.quoted_table_name}.deleted_at IS NULL or #{Spree::Product.quoted_table_name}.deleted_at >= ?", Time.current)
          end

          scope :with_master_price, -> do
            joins(:master).where(Spree::Price.where(Spree::Variant.arel_table[:id].eq(Spree::Price.arel_table[:variant_id])).arel.exists)
          end
          # Can't use add_search_scope for this as it needs a default argument
          def self.available(available_on = nil)
            with_master_price.where("#{Spree::Product.quoted_table_name}.available_on <= ?", available_on || Time.current)
          end
          search_scopes << :available

          add_search_scope :taxons_name_eq do |name|
            group("spree_products.id").joins(:taxons).where(Spree::Taxon.arel_table[:name].eq(name))
          end

          def self.with_variant_sku_cont(sku)
            sku_match = "%#{sku}%"
            variant_table = Spree::Variant.arel_table
            subquery = Spree::Variant.where(variant_table[:sku].matches(sku_match).and(variant_table[:product_id].eq(arel_table[:id])))
            where(subquery.arel.exists)
          end

          def self.distinct_by_product_ids(sort_order = nil)
            Spree::Deprecation.warn "Product.distinct_by_product_ids is deprecated and should not be used"

            sort_column = sort_order.split(" ").first

            # Postgres will complain when using ordering by expressions not present in
            # SELECT DISTINCT. e.g.
            #
            #   PG::InvalidColumnReference: ERROR:  for SELECT DISTINCT, ORDER BY
            #   expressions must appear in select list. e.g.
            #
            #   SELECT  DISTINCT "spree_products".* FROM "spree_products" LEFT OUTER JOIN
            #   "spree_variants" ON "spree_variants"."product_id" = "spree_products"."id" AND "spree_variants"."is_master" = 't'
            #   AND "spree_variants"."deleted_at" IS NULL LEFT OUTER JOIN "spree_prices" ON
            #   "spree_prices"."variant_id" = "spree_variants"."id" AND "spree_prices"."currency" = 'USD'
            #   AND "spree_prices"."deleted_at" IS NULL WHERE "spree_products"."deleted_at" IS NULL AND ('t'='t')
            #   ORDER BY "spree_prices"."amount" ASC LIMIT 10 OFFSET 0
            #
            # Don't allow sort_column, a variable coming from params,
            # to be anything but a column in the database
            if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL' && !column_names.include?(sort_column)
              all
            else
              distinct
            end
          end

          class << self
            private

            def price_table_name
              Spree::Price.quoted_table_name
            end

            # specifically avoid having an order for taxon search (conflicts with main order)
            def prepare_taxon_conditions(taxons)
              ids = taxons.flat_map { |taxon| taxon.self_and_descendants.pluck(:id) }.uniq
              joins(:taxons).where("#{Spree::Taxon.table_name}.id" => ids)
            end

            # Produce an array of keywords for use in scopes.
            # Always return array with at least an empty string to avoid SQL errors
            def prepare_words(words)
              return [''] if words.blank?

              splitted = words.split(/[,\s]/).map(&:strip)
              splitted.any? ? splitted : ['']
            end

            def get_taxons(*ids_or_records_or_names)
              taxons = Spree::Taxon.table_name
              ids_or_records_or_names.flatten.map { |taxon|
                case taxon
                when Integer then Spree::Taxon.find_by(id: taxon)
                when ActiveRecord::Base then taxon
                when String
                  Spree::Taxon.find_by(name: taxon) ||
                    Spree::Taxon.where("#{taxons}.permalink LIKE ? OR #{taxons}.permalink = ?", "%/#{taxon}/", "#{taxon}/").first
                end
              }.compact.flatten.uniq
            end
          end
        end
      end

      ::Spree::Product.prepend self
    end
  end
end
