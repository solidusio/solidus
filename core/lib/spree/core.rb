require 'rails/all'
require 'active_merchant'
require 'acts_as_list'
require 'awesome_nested_set'
require 'cancan'
require 'friendly_id'
require 'kaminari'
require 'mail'
require 'monetize'
require 'paperclip'
require 'paranoia'
require 'premailer/rails'
require 'ransack'
require 'state_machines-activerecord'
require 'responders'

# This is required because ActiveModel::Validations#invalid? conflicts with the
# invalid state of a Payment. In the future this should be removed.
StateMachines::Machine.ignore_method_conflicts = true

module Spree
  mattr_accessor :user_class

  def self.user_class
    if @@user_class.is_a?(Class)
      raise "Spree.user_class MUST be a String or Symbol object, not a Class object."
    elsif @@user_class.is_a?(String) || @@user_class.is_a?(Symbol)
      @@user_class.to_s.constantize
    end
  end

  # Used to configure Spree.
  #
  # Example:
  #
  #   Spree.config do |config|
  #     config.track_inventory_levels = false
  #   end
  #
  # This method is defined within the core gem on purpose.
  # Some people may only wish to use the Core part of Spree.
  def self.config(&_block)
    yield(Spree::Config)
  end

  module Core
    autoload :ProductFilters, "spree/core/product_filters"

    def self.const_missing(name)
      case name
      when :AdjustmentSource, :CalculatedAdjustments, :UserAddress, :UserPaymentSource
        Spree::Deprecation.warn("Spree::Core::#{name} is deprecated! Use Spree::#{name} instead.", caller)
        Spree.const_get(name)
      else
        super
      end
    end

    class GatewayError < RuntimeError; end
    class DestroyWithOrdersError < StandardError; end
  end
end

require 'spree/core/version'

require 'spree/core/class_constantizer'
require 'spree/core/environment_extension'
require 'spree/core/environment/calculators'
require 'spree/core/environment'
require 'spree/promo/environment'
require 'spree/migrations'
require 'spree/migration_helpers'
require 'spree/core/engine'

require 'spree/i18n'
require 'spree/localized_number'
require 'spree/money'
require 'spree/permitted_attributes'

require 'spree/core/delegate_belongs_to'
require 'spree/core/importer'
require 'spree/core/permalinks'
require 'spree/core/product_duplicator'
require 'spree/core/current_store'
require 'spree/core/controller_helpers/auth'
require 'spree/core/controller_helpers/common'
require 'spree/core/controller_helpers/order'
require 'spree/core/controller_helpers/payment_parameters'
require 'spree/core/controller_helpers/pricing'
require 'spree/core/controller_helpers/respond_with'
require 'spree/core/controller_helpers/search'
require 'spree/core/controller_helpers/store'
require 'spree/core/controller_helpers/strong_parameters'
require 'spree/core/unreturned_item_charger'
require 'spree/core/role_configuration'
require 'spree/core/stock_configuration'
require 'spree/permission_sets'
require 'spree/deprecation'

require 'spree/mailer_previews/order_preview'
require 'spree/mailer_previews/carton_preview'
require 'spree/mailer_previews/reimbursement_preview'

require 'spree/core/price_migrator'
