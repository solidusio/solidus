# frozen_string_literal: true

namespace :payment_method do
  desc "Deactivates old payment methods and fixes ActiveRecord::SubclassNotFound error, "\
  "which happens after switching Payment Service Provider."
  task deactivate_unsupported_payment_methods: :environment do
    Spree::PaymentMethod.pluck(:id, :type).select do |id, type|
      type.constantize
    rescue NameError
      fix_payment_method_record(id, type)
    end
  end

  def fix_payment_method_record(id, previous_type)
    connection = ActiveRecord::Base.connection
    false_value = connection.quoted_false
    connection.exec_update(<<-SQL
      UPDATE spree_payment_methods
      SET
        type='#{Spree::PaymentMethod.name}',
        type_before_removal='#{previous_type}',
        active=#{false_value},
        available_to_users=#{false_value},
        available_to_admin=#{false_value}
      WHERE id=#{id};
    SQL
    )
  end
end
