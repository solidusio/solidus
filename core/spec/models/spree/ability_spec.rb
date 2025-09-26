# frozen_string_literal: true

require "rails_helper"
require "cancan"
require "cancan/matchers"
require "spree/testing_support/ability_helpers"

RSpec.describe Spree::Ability, type: :model do
  let(:user) { build(:user) }
  let(:ability) { Spree::Ability.new(user) }
  let(:token) { nil }

  after(:each) {
    Spree::Ability.abilities = Set.new
  }

  describe "#initialize" do
    subject { Spree::Ability.new(user) }

    it "activates permissions from the role configuration" do
      expect(Spree::Config.roles).to receive(:activate_permissions!)
        .once

      subject
    end
  end

  context "register_ability" do
    it "should add the ability to the list of abilties" do
      foo_ability = Class.new do
        include CanCan::Ability

        def initialize(_user)
          can :index, Spree::Order
        end
      end

      Spree::Ability.register_ability(foo_ability)
      expect(Spree::Ability.new(user).abilities).not_to be_empty
    end

    it "should apply the registered abilities permissions" do
      foo_ability = Class.new do
        include CanCan::Ability

        def initialize(_user)
          can :index, Spree::Order
          can :update, Spree::Order do |order|
            order.id == 1
          end
        end
      end

      Spree::Ability.register_ability(foo_ability)
      expect(Spree::Ability.new(user).can?(:update, mock_model(Spree::Order, user: nil, id: 1))).to be true
    end
  end

  context "for general resource" do
    let(:resource) { Object.new }

    context "with admin user" do
      let(:user) { create :admin_user }
      it_should_behave_like "access granted"
      it_should_behave_like "index allowed"
    end

    context "with customer" do
      it_should_behave_like "access denied"
      it_should_behave_like "no index allowed"
    end
  end

  context "for admin protected resources" do
    let(:resource) { Object.new }
    let(:resource_shipment) { Spree::Shipment.new }
    let(:resource_product) { Spree::Product.new }
    let(:resource_user) { create :user }
    let(:resource_order) { Spree::Order.new }
    let(:fakedispatch_user) { Spree.user_class.create }
    let(:fakedispatch_ability) { Spree::Ability.new(fakedispatch_user) }

    context "with admin user" do
      it "should be able to admin" do
        user.spree_roles << Spree::Role.find_or_create_by(name: "admin")
        expect(ability).to be_able_to :admin, resource
        expect(ability).to be_able_to :index, resource_order
        expect(ability).to be_able_to :show, resource_product
        expect(ability).to be_able_to :create, resource_user
      end
    end

    context "with fakedispatch user" do
      it "should be able to admin on the order and shipment pages" do
        user.spree_roles << Spree::Role.find_or_create_by(name: "bar")

        bar_ability = Class.new do
          include CanCan::Ability

          def initialize(user)
            if user.has_spree_role? "bar"
              can [:admin, :index, :show], Spree::Order
              can [:admin, :manage], Spree::Shipment
            end
          end
        end
        Spree::Ability.register_ability(bar_ability)

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
      end
    end

    context "with customer" do
      it "should not be able to admin" do
        expect(ability).not_to be_able_to :admin, resource
        expect(ability).not_to be_able_to :admin, resource_order
        expect(ability).not_to be_able_to :admin, resource_product
        expect(ability).not_to be_able_to :admin, resource_user
      end
    end
  end

  context "as Guest User" do
    context "for Country" do
      let(:resource) { Spree::Country.new }
      context "requested by any user" do
        it_should_behave_like "read only"
      end
    end

    context "for OptionType" do
      let(:resource) { Spree::OptionType.new }
      context "requested by any user" do
        it_should_behave_like "read only"
      end
    end

    context "for OptionValue" do
      let(:resource) { Spree::OptionType.new }
      context "requested by any user" do
        it_should_behave_like "read only"
      end
    end

    context "for Order" do
      let(:resource) { Spree::Order.new }

      context "requested by same user" do
        before(:each) { resource.user = user }
        it_should_behave_like "access granted"
        it_should_behave_like "no index allowed"
      end

      context "requested by other user" do
        before(:each) { resource.user = Spree.user_class.new }
        it { expect(ability).not_to be_able_to(:show, resource) }
        it { expect(ability).to_not be_able_to(:create, resource) }
      end

      context "requested with proper token" do
        let(:token) { "TOKEN123" }
        before(:each) { allow(resource).to receive_messages guest_token: "TOKEN123" }
        it_should_behave_like "access granted"
        it_should_behave_like "no index allowed"
      end

      context "requested with inproper token" do
        let(:token) { "FAIL" }
        before(:each) { allow(resource).to receive_messages guest_token: "TOKEN123" }
        it { expect(ability).not_to be_able_to(:show, resource, token) }
        it { expect(ability).to_not be_able_to(:create, resource, token) }
      end
    end

    context "for Product" do
      let(:resource) { Spree::Product.new }
      context "requested by any user" do
        it_should_behave_like "read only"
      end
    end

    context "for ProductProperty" do
      let(:resource) { Spree::Product.new }
      context "requested by any user" do
        it_should_behave_like "read only"
      end
    end

    context "for Property" do
      let(:resource) { Spree::Product.new }
      context "requested by any user" do
        it_should_behave_like "read only"
      end
    end

    context "for State" do
      let(:resource) { Spree::State.new }
      context "requested by any user" do
        it_should_behave_like "read only"
      end
    end

    context "for Stock Item" do
      let(:resource) { Spree::StockItem.new }
      context "active stock location" do
        before { resource.build_stock_location(active: true) }
        it_should_behave_like "read only"
      end

      context "inactive stock location" do
        before { resource.build_stock_location(active: false) }
        it_should_behave_like "access denied"
      end
    end

    context "for Stock Location" do
      let(:resource) { Spree::StockLocation.new }
      context "active" do
        before { resource.active = true }
        it_should_behave_like "read only"
      end

      context "inactive" do
        before { resource.active = false }
        it_should_behave_like "access denied"
      end
    end

    context "for Taxons" do
      let(:resource) { Spree::Taxon.new }
      context "requested by any user" do
        it_should_behave_like "read only"
      end
    end

    context "for Taxonomy" do
      let(:resource) { Spree::Taxonomy.new }
      context "requested by any user" do
        it_should_behave_like "read only"
      end
    end

    context "for User" do
      context "requested by same user" do
        let(:resource) { user }
        it_should_behave_like "access granted"
        it_should_behave_like "no index allowed"
      end
      context "requested by other user" do
        let(:resource) { Spree.user_class.create }
        it_should_behave_like "create only"
      end
    end

    context "for Variant" do
      let(:resource) { Spree::Variant.new }
      context "requested by any user" do
        it_should_behave_like "read only"
      end
    end

    context "for Zone" do
      let(:resource) { Spree::Zone.new }
      context "requested by any user" do
        it_should_behave_like "read only"
      end
    end
  end
end
