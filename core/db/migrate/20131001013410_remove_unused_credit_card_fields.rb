class RemoveUnusedCreditCardFields < ActiveRecord::Migration
  def up
    remove_column :solidus_credit_cards, :start_month if column_exists?(:solidus_credit_cards, :start_month)
    remove_column :solidus_credit_cards, :start_year if column_exists?(:solidus_credit_cards, :start_year)
    remove_column :solidus_credit_cards, :issue_number if column_exists?(:solidus_credit_cards, :issue_number)
  end
  def down
    add_column :solidus_credit_cards, :start_month,  :string
    add_column :solidus_credit_cards, :start_year,   :string
    add_column :solidus_credit_cards, :issue_number, :string
  end

  def column_exists?(table, column)
    ActiveRecord::Base.connection.column_exists?(table, column)
  end
end
