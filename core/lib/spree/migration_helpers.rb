# frozen_string_literal: true

module Spree
  module MigrationHelpers
    def safe_remove_index(table, column)
      remove_index(table, column) if index_exists?(table, column)
    end

    def safe_add_index(table, column, options = {})
      if columns_exist?(table, column) && !index_exists?(table, column, options)
        add_index(table, column, options)
      end
    end

    private

    def columns_exist?(table, columns)
      Array.wrap(columns).all? { |column| column_exists?(table, column) }
    end
  end
end
