class UpdatePromotionCodeValueCollation < ActiveRecord::Migration[7.0]
  def up
    return unless mysql?

    collation = use_accent_sensitive_collation? ? 'utf8mb4_0900_as_cs' : 'utf8mb4_bin'
    change_column :solidus_promotions_promotion_codes, :value, :string,
                  collation: collation
  end

  def down
    return unless mysql?

    change_column :solidus_promotions_promotion_codes, :value, :string,
                  collation: 'utf8mb4_general_ci'
  end

  private

  def mysql?
    ActiveRecord::Base.connection.adapter_name.downcase.include?('mysql')
  end

  def use_accent_sensitive_collation?
    !mariadb? && mysql_version >= 8.0
  end

  def mariadb?
    version_string.include?('mariadb')
  end

  def mysql_version
    version_string.to_f
  end

  def version_string
    @version_string ||= ActiveRecord::Base.connection.select_value('SELECT VERSION()').downcase
  end
end
