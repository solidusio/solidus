# frozen_string_literal: true

module Solidus
  class Product < Solidus::Base
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
            joins(master: :default_price).order(Solidus::Price.arel_table[:amount].asc)
          end

          add_search_scope :descend_by_master_price do
            joins(master: :default_price).order(Solidus::Price.arel_table[:amount].desc)
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
          #   Solidus::Product.joins(:taxons).where(Taxon.table_name => { id: taxon.id })
          #
          # If you're using count on the result of this scope, you must use the
          # `:distinct` option as well:
          #
          #   Solidus::Product.in_taxon(taxon).count(distinct: true)
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
              .select(Solidus::Classification.arel_table[:position])
              .order(Solidus::Classification.arel_table[:position].asc)
          end

          # This scope selects products in all taxons AND all its descendants
          # If you need products only within one taxon use
          #
          #   Solidus::Product.taxons_id_eq([x,y])
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
              .where("#{Solidus::ProductProperty.table_name}.value = ?", value)
              .where(property_conditions(property))
          end

          add_search_scope :with_option do |option|
            option_types = Solidus::OptionType.table_name
            conditions = case option
                         when String     then { "#{option_types}.name" => option }
                         when OptionType then { "#{option_types}.id" => option.id }
                         else { "#{option_types}.id" => option.to_i }
            end

            joins(:option_types).where(conditions)
          end

          add_search_scope :with_option_value do |option, value|
            option_values = Solidus::OptionValue.table_name
            option_type_id = case option
                             when String then Solidus::OptionType.find_by(name: option) || option.to_i
                             when Solidus::OptionType then option.id
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
              where("#{Solidus::OptionValue.table_name}.name = ? OR #{Solidus::ProductProperty.table_name}.value = ?", value, value)
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
               COUNT(#{Solidus::LineItem.quoted_table_name}.id)
             FROM
               #{Solidus::LineItem.quoted_table_name}
             JOIN
               #{Solidus::Variant.quoted_table_name} AS popular_variants
             ON
               popular_variants.id = #{Solidus::LineItem.quoted_table_name}.variant_id
             WHERE
               popular_variants.product_id = #{Solidus::Product.quoted_table_name}.id
           ), 0) DESC
        })
          end

          add_search_scope :not_deleted do
            where("#{Solidus::Product.quoted_table_name}.deleted_at IS NULL or #{Solidus::Product.quoted_table_name}.deleted_at >= ?", Time.current)
          end

          scope :with_master_price, -> do
            joins(:master).where(Solidus::Price.where(Solidus::Variant.arel_table[:id].eq(Solidus::Price.arel_table[:variant_id])).arel.exists)
          end
          # Can't use add_search_scope for this as it needs a default argument
          def self.available(available_on = nil)
            with_master_price.where("#{Solidus::Product.quoted_table_name}.available_on <= ?", available_on || Time.current)
          end
          search_scopes << :available

          add_search_scope :taxons_name_eq do |name|
            group("spree_products.id").joins(:taxons).where(Solidus::Taxon.arel_table[:name].eq(name))
          end

          def self.with_variant_sku_cont(sku)
            sku_match = "%#{sku}%"
            variant_table = Solidus::Variant.arel_table
            subquery = Solidus::Variant.where(variant_table[:sku].matches(sku_match).and(variant_table[:product_id].eq(arel_table[:id])))
            where(subquery.arel.exists)
          end

          def self.distinct_by_product_ids(sort_order = nil)
            Solidus::Deprecation.warn "Product.distinct_by_product_ids is deprecated and should not be used"

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
              Solidus::Price.quoted_table_name
            end

            # specifically avoid having an order for taxon search (conflicts with main order)
            def prepare_taxon_conditions(taxons)
              ids = taxons.map { |taxon| taxon.self_and_descendants.pluck(:id) }.flatten.uniq
              joins(:taxons).where("#{Solidus::Taxon.table_name}.id" => ids)
            end

            # Produce an array of keywords for use in scopes.
            # Always return array with at least an empty string to avoid SQL errors
            def prepare_words(words)
              return [''] if words.blank?
              a = words.split(/[,\s]/).map(&:strip)
              a.any? ? a : ['']
            end

            def get_taxons(*ids_or_records_or_names)
              taxons = Solidus::Taxon.table_name
              ids_or_records_or_names.flatten.map { |t|
                case t
                when Integer then Solidus::Taxon.find_by(id: t)
                when ActiveRecord::Base then t
                when String
                  Solidus::Taxon.find_by(name: t) ||
                    Solidus::Taxon.where("#{taxons}.permalink LIKE ? OR #{taxons}.permalink = ?", "%/#{t}/", "#{t}/").first
                end
              }.compact.flatten.uniq
            end
          end
        end
      end

      ::Solidus::Product.prepend self
    end
  end
end
