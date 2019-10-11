# frozen_string_literal: true

require 'rails_helper'
require 'cancan'
require 'cancan/matchers'
require 'spree/testing_support/ability_helpers'

Solidus::Deprecation.silence do
  require 'spree/testing_support/bar_ability'
end

# Fake ability for testing registration of additional abilities
class FooAbility
  include CanCan::Ability

  def initialize(_user)
    # allow anyone to perform index on Order
    can :index, Solidus::Order
    # allow anyone to update an Order with id of 1
    can :update, Solidus::Order do |order|
      order.id == 1
    end
  end
end

RSpec.describe Solidus::Ability, type: :model do
  let(:user) { build(:user) }
  let(:ability) { Solidus::Ability.new(user) }
  let(:token) { nil }

  after(:each) {
    Solidus::Ability.abilities = Set.new
  }

  describe "#initialize" do
    subject { Solidus::Ability.new(user) }

    it "activates permissions from the role configuration" do
      expect(Solidus::Config.roles).to receive(:activate_permissions!).
        once

      subject
    end
  end

  context 'register_ability' do
    it 'should add the ability to the list of abilties' do
      Solidus::Ability.register_ability(FooAbility)
      expect(Solidus::Ability.new(user).abilities).not_to be_empty
    end

    it 'should apply the registered abilities permissions' do
      Solidus::Ability.register_ability(FooAbility)
      expect(Solidus::Ability.new(user).can?(:update, mock_model(Solidus::Order, user: nil, id: 1))).to be true
    end
  end

  context 'for general resource' do
    let(:resource) { Object.new }

    context 'with admin user' do
      let(:user) { build :admin_user }
      it_should_behave_like 'access granted'
      it_should_behave_like 'index allowed'
    end

    context 'with customer' do
      it_should_behave_like 'access denied'
      it_should_behave_like 'no index allowed'
    end
  end

  context 'for admin protected resources' do
    let(:resource) { Object.new }
    let(:resource_shipment) { Solidus::Shipment.new }
    let(:resource_product) { Solidus::Product.new }
    let(:resource_user) { create :user }
    let(:resource_order) { Solidus::Order.new }
    let(:fakedispatch_user) { Solidus.user_class.create }
    let(:fakedispatch_ability) { Solidus::Ability.new(fakedispatch_user) }

    context 'with admin user' do
      it 'should be able to admin' do
        user.spree_roles << Solidus::Role.find_or_create_by(name: 'admin')
        expect(ability).to be_able_to :admin, resource
        expect(ability).to be_able_to :index, resource_order
        expect(ability).to be_able_to :show, resource_product
        expect(ability).to be_able_to :create, resource_user
      end
    end

    context 'with fakedispatch user' do
      it 'should be able to admin on the order and shipment pages' do
        user.spree_roles << Solidus::Role.find_or_create_by(name: 'bar')

        Solidus::Ability.register_ability(BarAbility)

        expect(ability).not_to be_able_to :admin, resource

        expect(ability).to be_able_to :admin, resource_order
        expect(ability).to be_able_to :index, resource_order
        expect(ability).not_to be_able_to :update, resource_order
        # ability.should_not be_able_to :create, resource_order # Fails

        expect(ability).to be_able_to :admin, resource_shipment
        expect(ability).to be_able_to :index, resource_shipment
        expect(ability).to be_able_to :create, resource_shipment

        expect(ability).not_to be_able_to :admin, resource_product
        expect(ability).not_to be_able_to :update, resource_product
        # ability.should_not be_able_to :show, resource_product # Fails

        expect(ability).not_to be_able_to :admin, resource_user
        expect(ability).not_to be_able_to :update, resource_user
        expect(ability).to be_able_to :update, user
        # ability.should_not be_able_to :create, resource_user # Fails
        # It can create new users if is has access to the :admin, User!!

        # TODO: change the Ability class so only users and customers get the extra premissions?

        Solidus::Ability.remove_ability(BarAbility)
      end
    end

    context 'with customer' do
      it 'should not be able to admin' do
        expect(ability).not_to be_able_to :admin, resource
        expect(ability).not_to be_able_to :admin, resource_order
        expect(ability).not_to be_able_to :admin, resource_product
        expect(ability).not_to be_able_to :admin, resource_user
      end
    end
  end

  context 'as Guest User' do
    context 'for Country' do
      let(:resource) { Solidus::Country.new }
      context 'requested by any user' do
        it_should_behave_like 'read only'
      end
    end

    context 'for OptionType' do
      let(:resource) { Solidus::OptionType.new }
      context 'requested by any user' do
        it_should_behave_like 'read only'
      end
    end

    context 'for OptionValue' do
      let(:resource) { Solidus::OptionType.new }
      context 'requested by any user' do
        it_should_behave_like 'read only'
      end
    end

    context 'for Order' do
      let(:resource) { Solidus::Order.new }

      context 'requested by same user' do
        before(:each) { resource.user = user }
        it_should_behave_like 'access granted'
        it_should_behave_like 'no index allowed'
      end

      context 'requested by other user' do
        before(:each) { resource.user = Solidus.user_class.new }
        it_should_behave_like 'create only'
      end

      context 'requested with proper token' do
        let(:token) { 'TOKEN123' }
        before(:each) { allow(resource).to receive_messages guest_token: 'TOKEN123' }
        it_should_behave_like 'access granted'
        it_should_behave_like 'no index allowed'
      end

      context 'requested with inproper token' do
        let(:token) { 'FAIL' }
        before(:each) { allow(resource).to receive_messages guest_token: 'TOKEN123' }
        it_should_behave_like 'create only'
      end
    end

    context 'for Product' do
      let(:resource) { Solidus::Product.new }
      context 'requested by any user' do
        it_should_behave_like 'read only'
      end
    end

    context 'for ProductProperty' do
      let(:resource) { Solidus::Product.new }
      context 'requested by any user' do
        it_should_behave_like 'read only'
      end
    end

    context 'for Property' do
      let(:resource) { Solidus::Product.new }
      context 'requested by any user' do
        it_should_behave_like 'read only'
      end
    end

    context 'for State' do
      let(:resource) { Solidus::State.new }
      context 'requested by any user' do
        it_should_behave_like 'read only'
      end
    end

    context 'for Stock Item' do
      let(:resource) { Solidus::StockItem.new }
      context 'active stock location' do
        before { resource.build_stock_location(active: true) }
        it_should_behave_like 'read only'
      end

      context 'inactive stock location' do
        before { resource.build_stock_location(active: false) }
        it_should_behave_like 'access denied'
      end
    end

    context 'for Stock Location' do
      let(:resource) { Solidus::StockLocation.new }
      context 'active' do
        before { resource.active = true }
        it_should_behave_like 'read only'
      end

      context 'inactive' do
        before { resource.active = false }
        it_should_behave_like 'access denied'
      end
    end

    context 'for Taxons' do
      let(:resource) { Solidus::Taxon.new }
      context 'requested by any user' do
        it_should_behave_like 'read only'
      end
    end

    context 'for Taxonomy' do
      let(:resource) { Solidus::Taxonomy.new }
      context 'requested by any user' do
        it_should_behave_like 'read only'
      end
    end

    context 'for User' do
      context 'requested by same user' do
        let(:resource) { user }
        it_should_behave_like 'access granted'
        it_should_behave_like 'no index allowed'
      end
      context 'requested by other user' do
        let(:resource) { Solidus.user_class.create }
        it_should_behave_like 'create only'
      end
    end

    context 'for Variant' do
      let(:resource) { Solidus::Variant.new }
      context 'requested by any user' do
        it_should_behave_like 'read only'
      end
    end

    context 'for Zone' do
      let(:resource) { Solidus::Zone.new }
      context 'requested by any user' do
        it_should_behave_like 'read only'
      end
    end
  end
end
