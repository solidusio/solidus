# frozen_string_literal: true

require 'solidus_legacy_promotions/migrations/promotions_with_code_handlers'

class RemoveCodeFromSpreePromotions < ActiveRecord::Migration[5.1]
  class Promotion < ActiveRecord::Base
    self.table_name = "spree_promotions"
    self.ignored_columns = %w(type)
  end

  def up
    if column_exists?(:spree_promotions, :code)
      promotions_with_code = Promotion.where.not(code: [nil, ''])

      if promotions_with_code.any?
        # You have some promotions with "code" field present! This is not good
        # since we are going to remove that column.
        #
        self.class.promotions_with_code_handler.new(self, promotions_with_code).call
      end

      remove_index :spree_promotions, name: :index_spree_promotions_on_code
      remove_column :spree_promotions, :code
    end
  end

  def down
    unless column_exists?(:spree_promotions, :code)
      add_column :spree_promotions, :code, :string
      add_index :spree_promotions, :code, name: :index_spree_promotions_on_code
    end
  end

  def self.promotions_with_code_handler
    # We propose different approaches, just pick the one that you prefer or
    # write your custom one.
    #
    # The fist one (raising an exception) is the default but you can
    # comment/uncomment the one then better fits you needs or use a
    # custom class or callable object.
    #
    SolidusLegacyPromotions::Migrations::PromotionWithCodeHandlers::RaiseException
    # SolidusLegacyPromotions::Migrations::PromotionWithCodeHandlers::MoveToSpreePromotionCode
    # SolidusLegacyPromotions::Migrations::PromotionWithCodeHandlers::DoNothing
  end
end
