# frozen_string_literal: true

Solidus::Deprecation.warn "BarAbility is deprecated. Use stub_authorization! instead"

# Fake ability for testing administration
# @private
class BarAbility
  include CanCan::Ability

  def initialize(user)
    user ||= Solidus::User.new
    if user.has_spree_role? 'bar'
      # allow dispatch to :admin, :index, and :show on Solidus::Order
      can [:admin, :index, :show], Solidus::Order
      # allow dispatch to :index, :show, :create and :update shipments on the admin
      can [:admin, :manage], Solidus::Shipment
    end
  end
end
