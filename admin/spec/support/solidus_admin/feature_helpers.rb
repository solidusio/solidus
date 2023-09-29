# frozen_string_literal: true

module SolidusAdmin
  module FeatureHelpers
    def sign_in(user)
      allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(user)
    end

    def stub_authorization!(user)
      ability = Spree::Ability.new(user)
      if block_given?
        yield ability
      else
        ability.can :manage, :all
      end
      allow_any_instance_of(SolidusAdmin::BaseController).to receive(:current_ability).and_return(ability)
      allow_any_instance_of(Spree::Admin::BaseController).to receive(:current_ability).and_return(ability)
    end
  end
end
