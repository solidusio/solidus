class RenameBogusGateways < ActiveRecord::Migration[5.0]
  def up
    ActiveRecord::Base.connection.execute <<-SQL.strip_heredoc
UPDATE spree_payment_methods SET type = 'Spree::PaymentMethod::BogusCreditCard' WHERE type = 'Spree::Gateway::Bogus';
UPDATE spree_payment_methods SET type = 'Spree::PaymentMethod::SimpleBogusCreditCard' WHERE type = 'Spree::Gateway::BogusSimple';
SQL
  end

  def up
    ActiveRecord::Base.connection.execute <<-SQL.strip_heredoc
UPDATE spree_payment_methods SET type = 'Spree::Gateway::Bogus' WHERE type = 'Spree::PaymentMethod::BogusCreditCard';
UPDATE spree_payment_methods SET type = 'Spree::Gateway::BogusSimple' WHERE type = 'Spree::PaymentMethod::SimpleBogusCreditCard';
SQL
  end
end
