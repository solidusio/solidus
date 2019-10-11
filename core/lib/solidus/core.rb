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

require 'solidus/deprecation'
require 'solidus/paranoia_deprecations'

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
  def self.config(&_block)
    yield(Solidus::Config)
  end

  module Core
    class GatewayError < RuntimeError; end

    include ActiveSupport::Deprecation::DeprecatedConstantAccessor
    deprecate_constant 'DestroyWithOrdersError', ActiveRecord::DeleteRestrictionError, deprecator: Solidus::Deprecation
  end
end

if Gem::Version.new(Rails.version) < Gem::Version.new('5.2')
  warn <<~HEREDOC
    Rails 5.1 (EOL) is deprecated and will not be supported anymore from the next Solidus version.
    Please, upgrade to a more recent Rails version.

    Read more on upgrading from Rails 5.1 to Rails 5.2 here:
    https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-5-1-to-rails-5-2

  HEREDOC
end

require 'solidus/core/version'

require 'solidus/core/active_merchant_dependencies'
require 'solidus/core/class_constantizer'
require 'solidus/core/environment_extension'
require 'solidus/core/environment/calculators'
require 'solidus/core/environment/promotions'
require 'solidus/core/environment'
require 'solidus/promo/environment'
require 'solidus/migrations'
require 'solidus/migration_helpers'
require 'solidus/event'
require 'solidus/core/engine'

require 'solidus/i18n'
require 'solidus/localized_number'
require 'solidus/money'
require 'solidus/permitted_attributes'

require 'solidus/core/importer'
require 'solidus/core/permalinks'
require 'solidus/core/product_duplicator'
require 'solidus/core/current_store'
require 'solidus/core/controller_helpers/auth'
require 'solidus/core/controller_helpers/common'
require 'solidus/core/controller_helpers/order'
require 'solidus/core/controller_helpers/payment_parameters'
require 'solidus/core/controller_helpers/pricing'
require 'solidus/core/controller_helpers/search'
require 'solidus/core/controller_helpers/store'
require 'solidus/core/controller_helpers/strong_parameters'
require 'solidus/core/role_configuration'
require 'solidus/core/state_machines'
require 'solidus/core/stock_configuration'
require 'solidus/core/validators/email'
require 'solidus/permission_sets'

require 'solidus/preferences/store'
require 'solidus/preferences/static_model_preferences'
require 'solidus/preferences/scoped_store'

require 'solidus/namespace_migration/model_naming'
require 'solidus/namespace_migration/spree_constant'
require 'solidus/namespace_migration/table_prefix'
require 'solidus/namespace_migration/controller_view_paths'
require 'solidus/namespace_migration/mailer_view_paths'
require 'solidus/namespace_migration/controller_belongs_to'
require 'solidus/namespace_migration/custom_validations_i18n'
require 'solidus/namespace_migration/model_partial_paths'
require 'solidus/namespace_migration'
