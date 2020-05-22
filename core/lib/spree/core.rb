# frozen_string_literal: true

require 'rails/all'
require 'acts_as_list'
require 'awesome_nested_set'
require 'cancan'
require 'friendly_id'
require 'kaminari/activerecord'
require 'mail'
require 'monetize'
require 'paperclip'
require 'paranoia'
require 'ransack'
require 'state_machines-activerecord'

require 'spree/deprecation'
require 'spree/paranoia_deprecations'

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
    class GatewayError < RuntimeError; end

    include ActiveSupport::Deprecation::DeprecatedConstantAccessor
    deprecate_constant 'DestroyWithOrdersError', ActiveRecord::DeleteRestrictionError, deprecator: Spree::Deprecation
  end
end

require 'spree/core/version'

require 'spree/core/active_merchant_dependencies'
require 'spree/core/class_constantizer'
require 'spree/core/environment_extension'
require 'spree/core/environment/calculators'
require 'spree/core/environment/promotions'
require 'spree/core/environment'
require 'spree/promo/environment'
require 'spree/migrations'
require 'spree/migration_helpers'
require 'spree/event'
require 'spree/core/engine'

require 'spree/i18n'
require 'spree/localized_number'
require 'spree/money'
require 'spree/permitted_attributes'

require 'spree/core/importer'
require 'spree/core/permalinks'
require 'spree/core/product_duplicator'
require 'spree/core/current_store'
require 'spree/core/controller_helpers/auth'
require 'spree/core/controller_helpers/common'
require 'spree/core/controller_helpers/current_host'
require 'spree/core/controller_helpers/order'
require 'spree/core/controller_helpers/payment_parameters'
require 'spree/core/controller_helpers/pricing'
require 'spree/core/controller_helpers/search'
require 'spree/core/controller_helpers/store'
require 'spree/core/controller_helpers/strong_parameters'
require 'spree/core/role_configuration'
require 'spree/core/state_machines'
require 'spree/core/stock_configuration'
require 'spree/core/validators/email'
require 'spree/permission_sets'

require 'spree/preferences/store'
require 'spree/preferences/static_model_preferences'
require 'spree/preferences/scoped_store'

if Rails.gem_version >= Gem::Version.new('6.1.0.alpha')
  require 'spree/awesome_nested_set_override'
end
