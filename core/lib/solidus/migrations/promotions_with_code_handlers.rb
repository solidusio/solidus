# frozen_string_literal: true

module Solidus
  module Migrations
    module PromotionWithCodeHandlers
      class PromotionCode < ActiveRecord::Base
        self.table_name = "spree_promotion_codes"
      end

      class Base
        attr_reader :migration_context, :promotions

        def initialize(migration_context, promotions)
          @migration_context = migration_context
          @promotions = promotions
        end
      end

      class RaiseException < Base
        def call
          # Please note that this will block the current migration and rollback all
          # the previous ones run with the same "rails db:migrate" command.
          #
          raise StandardError, "You are trying to drop 'code' column from "\
            "spree_promotions table but you have at least one record with that "\
            "column filled. Please take care of that or you could lose data. See:" \
            "\n" \
            "https://github.com/solidusio/solidus/pull/3028"\
            "\n"
        end
      end

      class MoveToSpreePromotionCode < Base
        def call
          # This is another possible approach, it will convert Spree::Promotion#code
          # to a Spree::PromotionCode before removing the `code` field.
          #
          # NOTE: promotion codes will be downcased and stripped
          promotions.find_each do |promotion|
            normalized_code = promotion.code.downcase.strip

            PromotionCode.find_or_create_by!(
              value: normalized_code,
              promotion_id: promotion.id
            ) do
              migration_context.say "Creating Spree::PromotionCode with value "\
               "'#{normalized_code}' for Spree::Promotion with id '#{promotion.id}'"
            end
          end
        end
      end

      class DoNothing < Base
        def call
          # This approach will delete all codes without taking any action. At
          # least we could print a message to track what we are deleting.
          #
          promotions.find_each do |promotion|
            migration_context.say "Code '#{promotion.code}' is going to be removed "\
              "from Spree::Promotion with id '#{promotion.id}'"
          end
        end
      end
    end
  end
end
