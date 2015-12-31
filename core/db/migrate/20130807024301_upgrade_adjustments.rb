class UpgradeAdjustments < ActiveRecord::Migration
  def up
    # Temporarily make originator association available
    Solidus::Adjustment.class_eval do
      belongs_to :originator, polymorphic: true
    end
    # Shipping adjustments are now tracked as fields on the object
    Solidus::Adjustment.where(:source_type => "Solidus::Shipment").find_each do |adjustment|
      # Account for possible invalid data
      next if adjustment.source.nil?
      adjustment.source.update_column(:cost, adjustment.amount)
      adjustment.destroy!
    end

    # Tax adjustments have their sources altered
    Solidus::Adjustment.where(:originator_type => "Solidus::TaxRate").find_each do |adjustment|
      adjustment.source_id = adjustment.originator_id
      adjustment.source_type = "Solidus::TaxRate"
      adjustment.save!
    end

    # Promotion adjustments have their source altered also
    Solidus::Adjustment.where(:originator_type => "Solidus::PromotionAction").find_each do |adjustment|
      next if adjustment.originator.nil?
      adjustment.source = adjustment.originator
      begin
        if adjustment.source.calculator_type == "Solidus::Calculator::FreeShipping"
          # Previously this was a Solidus::Promotion::Actions::CreateAdjustment
          # And it had a calculator to work out FreeShipping
          # In Spree 2.2, the "calculator" is now the action itself.
          adjustment.source.becomes(Solidus::Promotion::Actions::FreeShipping)
        end
      rescue
        # Fail silently. This is primarily in instances where the calculator no longer exists
      end

      adjustment.save!
    end
  end
end
