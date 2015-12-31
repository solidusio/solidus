require 'spec_helper'

describe Solidus::RoleConfiguration do
  class DummyPermissionSet < Solidus::PermissionSets::Base
    def activate!
      can :manage, :things
    end
  end
  class OtherDummyPermissionSet < Solidus::PermissionSets::Base; end

  let(:instance) { described_class.instance }

  around do |example|
    @original_roles = instance.roles.dup
    instance.roles.clear
    example.run
    instance.roles = @original_roles
  end

  describe ".configure" do
    it "yields with the instance" do
      expect { |b| described_class.configure(&b) }.to yield_with_args(described_class.instance)
    end

    it "only yields once" do
      expect { |b| described_class.configure(&b) }.to yield_control.once
    end
  end

  describe "#assign_permissions" do
    let(:name) { "thing" }
    subject { instance.assign_permissions name, [DummyPermissionSet]}

    context "when a role for the name exists" do
      before do
        instance.roles.merge!({ name => described_class::Role.new(name, Set.new(existing_roles)) })
      end

      context "when adding duplicate permission sets" do
        let(:existing_roles) { [DummyPermissionSet] }

        it "does not add another role" do
          expect{subject}.to_not change{instance.roles.count}
        end

        it "does not add duplicate permission sets" do
          subject
          role = instance.roles.values.detect { |r| r.name == name }
          expect(role.permission_sets).to match_array([DummyPermissionSet])
        end
      end

      context "when adding new permission sets to an existing role" do
        let(:existing_roles) { [OtherDummyPermissionSet] }

        it "does not add another role" do
          expect{subject}.to_not change{instance.roles.count}
        end

        it "appends the permission set to the existing role" do
          subject
          role = instance.roles.values.detect { |r| r.name == name }
          expect(role.permission_sets).to match_array([OtherDummyPermissionSet, DummyPermissionSet])
        end
      end
    end

    context "when a role for the name does not yet exist" do
      it "creates a new role" do
        expect{subject}.to change{instance.roles.count}.from(0).to(1)
      end

      it "sets the roles name accordingly" do
        subject
        expect(instance.roles.values.first.name).to eql(name)
      end

      it "sets the permission sets accordingly" do
        subject
        expect(instance.roles.values.first.permission_sets).to match_array([DummyPermissionSet])
      end
    end
  end

  describe "#activate_permissions!" do
    let(:user) { build :user }
    let(:role_name) { "testrole" }
    let(:ability) { DummyAbility.new }

    before do
      user.spree_roles = user_roles.map do |role|
        Solidus::Role.create!(name: role)
      end
    end

    subject { described_class.instance.activate_permissions! ability, user }

    context "when the configuration has roles" do
      before do
        instance.roles.merge!({ role_name => described_class::Role.new(role_name, [DummyPermissionSet])})
      end

      context "default_role" do
        let(:role_name) { 'default' }

        context "when the user has no roles" do
          let(:user_roles) {[]}

          it "activates the applicable permissions on the ability" do
            expect{subject}.to change{ability.can? :manage, :things}.
              from(false).
              to(true)
          end
        end

        context "when the user has a different role" do
          let(:user_roles) {[]}

          it "activates the applicable permissions on the ability" do
            expect{subject}.to change{ability.can? :manage, :things}.
              from(false).
              to(true)
          end
        end
      end

      context "when the configuration has applicable roles" do
        let(:user_roles) {[role_name, "someotherrandomrole"]}

        it "activates the applicable permissions on the ability" do
          expect{subject}.to change{ability.can? :manage, :things}.
            from(false).
            to(true)
        end
      end

      context "when the configuration does not have applicable roles" do
        let(:user_roles) {["somerandomrole"]}

        it "doesn't activate non matching roles" do
          subject
          expect(ability.can? :manage, :things).to be false
        end
      end
    end

    context "when the configuration does not have roles" do
      let(:user_roles) {["somerandomrole"]}

      it "doesnt activate any new permissions" do
        subject
        expect(ability.can? :manage, :things).to be false
      end
    end
  end
end
