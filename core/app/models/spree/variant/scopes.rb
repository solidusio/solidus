# frozen_string_literal: true

module Spree
  class Variant < Spree::Base
    module Scopes
      def self.prepended(base)
        base.class_eval do
          # FIXME: WARNING tested only under sqlite and postgresql
          scope :descend_by_popularity, -> {
            order(Arel.sql("COALESCE((SELECT COUNT(*) FROM  #{Spree::LineItem.quoted_table_name} GROUP BY #{Spree::LineItem.quoted_table_name}.variant_id HAVING #{Spree::LineItem.quoted_table_name}.variant_id = #{Spree::Variant.quoted_table_name}.id), 0) DESC"))
          }

          class << self
            # Returns variants that match a given option value
            #
            # Example:
            #
            # product.variants_including_master.has_option(OptionType.find_by(name: 'shoe-size'), OptionValue.find_by(name: '8'))
            def has_option(option_type, *option_values)
              option_types = Spree::OptionType.table_name

              option_type_conditions = case option_type
                                       when OptionType then { "#{option_types}.name" => option_type.name }
                                       when String     then { "#{option_types}.name" => option_type }
                                       else { "#{option_types}.id" => option_type }
                                       end

              relation = joins(option_values: :option_type).where(option_type_conditions)

              option_values.each do |option_value|
                option_value_conditions = case option_value
                                          when OptionValue then { "#{Spree::OptionValue.table_name}.name" => option_value.name }
                                          when String      then { "#{Spree::OptionValue.table_name}.name" => option_value }
                                          else { "#{Spree::OptionValue.table_name}.id" => option_value }
                                          end
                relation = relation.where(option_value_conditions)
              end

              relation
            end

            alias_method :has_options, :has_option
          end
        end
      end

      ::Spree::Variant.prepend self
    end
  end
end
