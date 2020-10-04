# frozen_string_literal: true

Spree::Deprecation.warn "BarAbility is deprecated. Use stub_authorization! instead"

# Fake ability for testing administration
# @private
class BarAbility
  include CanCan::Ability

  def initialize(user)
    user ||= Spree::User.new
    if user.has_spree_role? 'bar'
      # allow dispatch to :admin, :index, and :show on Spree::Order
      can [:admin, :index, :show], Spree::Order
      # allow dispatch to :index, :show, :create and :update shipments on the admin
      can [:admin, :manage], Spree::Shipment
    end
  end
end
