module Spree
  module TestingSupport
    module AuthorizationHelpers
      module CustomAbility
        def stub_permissions!(permission_sets: [Spree::PermissionSets::SuperUser])
          # Since we cannot reliably stub the user or ability for capybara specs,
          # we change the permissions for the default user, and change them back in the after(:all).
          before(:all) { Spree::RoleConfiguration.instance.assign_permissions "default", permission_sets }
          after(:all)  { Spree::RoleConfiguration.instance.unassign_permissions "default", permission_sets }
        end
        def custom_authorization!(&block)
          ActiveSupport::Deprecation.warn "custom_authorization! will be deprecated in the next release, please use stub_authorization!", caller
          stub_authorization!(&block)
        end
      end

      module Controller
        include CustomAbility
        def stub_authorization!(permission_sets: [Spree::PermissionSets::SuperUser])
          if block_given?
            ability = Class.new do
              include CanCan::Ability
              define_method(:initialize, yield)
            end
            before(:all) { Spree::Ability.register_ability(ability) }
            after(:all)  { Spree::Ability.remove_ability(ability) }
          else
            stub_permissions!(permission_sets: permission_sets)
          end

          before do
            # This is used in admin controller specs.
            allow(controller).to receive(:current_ability).and_return(Spree::Ability.new(nil))
          end
        end

      end

      module Request
        include CustomAbility
        def stub_authorization!(permission_sets: [Spree::PermissionSets::SuperUser])
          if block_given?
            ActiveSupport::Deprecation.warn "stub_authorization! with a block will be deprecated in the next release, please use permission sets to specify authorization instead", caller
          end
          stub_permissions!(permission_sets: permission_sets)

          before do
            # This is used in admin feature specs to stub ajax calls to the api.
            allow(Spree.user_class).to receive(:find_by).
              with(hash_including(:spree_api_key)).
              and_return(Spree.user_class.new)
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.extend Spree::TestingSupport::AuthorizationHelpers::Controller, type: :controller
  config.extend Spree::TestingSupport::AuthorizationHelpers::Request, type: :feature
end
