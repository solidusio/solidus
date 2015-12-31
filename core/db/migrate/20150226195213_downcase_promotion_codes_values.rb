class DowncasePromotionCodesValues < ActiveRecord::Migration
  def up
    Solidus::PromotionCode.update_all("value = lower(value)")
    Solidus::Promotion.where.not(code: nil).update_all("code = lower(code)")
  end

  def down
    # can't tell which things we updated vs what things were like before
    raise ActiveRecord::IrreversibleMigration
  end
end
