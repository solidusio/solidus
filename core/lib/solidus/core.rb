require 'rails/all'
require 'active_merchant'
require 'acts_as_list'
require 'awesome_nested_set'
require 'cancan'
require 'friendly_id'
require 'font-awesome-rails'
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

module Solidus

  mattr_accessor :user_class

  def self.user_class
    if @@user_class.is_a?(Class)
      raise "Solidus.user_class MUST be a String or Symbol object, not a Class object."
    elsif @@user_class.is_a?(String) || @@user_class.is_a?(Symbol)
      @@user_class.to_s.constantize
    end
  end

  # Used to configure Solidus.
  #
  # Example:
  #
  #   Solidus.config do |config|
  #     config.track_inventory_levels = false
  #   end
  #
  # This method is defined within the core gem on purpose.
  # Some people may only wish to use the Core part of Solidus.
  def self.config(&block)
    yield(Solidus::Config)
  end

  module Core
    autoload :ProductFilters, "solidus/core/product_filters"

    def self.const_missing(name)
      case name
      when :AdjustmentSource, :CalculatedAdjustments, :UserAddress, :UserPaymentSource
        ActiveSupport::Deprecation.warn("Solidus::Core::#{name} is deprecated! Use Solidus::#{name} instead.", caller)
        Solidus.const_get(name)
      else
        super
      end
    end

    class GatewayError < RuntimeError; end
    class DestroyWithOrdersError < StandardError; end
  end
end

require 'solidus/core/version'

require 'solidus/core/environment_extension'
require 'solidus/core/environment/calculators'
require 'solidus/core/environment'
require 'solidus/promo/environment'
require 'solidus/migrations'
require 'solidus/core/engine'

require 'solidus/i18n'
require 'solidus/localized_number'
require 'solidus/money'
require 'solidus/permitted_attributes'

require 'solidus/core/delegate_belongs_to'
require 'solidus/core/importer'
require 'solidus/core/permalinks'
require 'solidus/core/product_duplicator'
require 'solidus/core/current_store'
require 'solidus/core/controller_helpers/auth'
require 'solidus/core/controller_helpers/common'
require 'solidus/core/controller_helpers/order'
require 'solidus/core/controller_helpers/payment_parameters'
require 'solidus/core/controller_helpers/respond_with'
require 'solidus/core/controller_helpers/search'
require 'solidus/core/controller_helpers/store'
require 'solidus/core/controller_helpers/strong_parameters'
require 'solidus/core/unreturned_item_charger'
require 'solidus/core/role_configuration'
require 'solidus/permission_sets'
require 'solidus/deprecation'

require 'solidus/mailer_previews/order_preview'
require 'solidus/mailer_previews/carton_preview'
