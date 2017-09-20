require 'rails/all'
require 'acts_as_list'
require 'awesome_nested_set'
require 'cancan'
require 'friendly_id'
require 'kaminari'
require 'mail'
require 'monetize'
require 'paperclip'
require 'paranoia'
require 'ransack'
require 'state_machines-activerecord'

require 'spree'
require 'spree/deprecation'

# This is required because ActiveModel::Validations#invalid? conflicts with the
# invalid state of a Payment. In the future this should be removed.
StateMachines::Machine.ignore_method_conflicts = true

module Spree
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
require 'spree/core/environment'
require 'spree/promo/environment'
require 'spree/migrations'
require 'spree/migration_helpers'
require 'spree/core/engine'

require 'spree/i18n'
require 'spree/localized_number'
require 'spree/money'
require 'spree/permitted_attributes'

require 'spree/core/importer'
require 'spree/core/permalinks'
require 'spree/core/product_duplicator'
require 'spree/core/current_store'
require 'spree/core/role_configuration'
require 'spree/core/stock_configuration'
require 'spree/permission_sets'

require 'spree/preferences/store'
require 'spree/preferences/static_model_preferences'
require 'spree/preferences/scoped_store'
