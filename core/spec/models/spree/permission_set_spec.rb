# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::PermissionSet, type: :model do
  describe "associations" do
    it "has many role_permissions" do
      association = described_class.reflect_on_association(:role_permissions)
      expect(association.macro).to eq(:has_many)
    end

    it "has many roles through role_permissions" do
      association = described_class.reflect_on_association(:roles)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:through]).to eq(:role_permissions)
    end
  end

  describe "validations" do
    it "is invalid without a name" do
      permission_set = described_class.new(set: "Spree::PermissionSet::OrderDisplay", category: "order", privilege: "display")
      expect(permission_set).not_to be_valid
      expect(permission_set.errors[:name]).to include("can't be blank")
    end

    it "is invalid without a set" do
      permission_set = described_class.new(name: "OrderDisplay", category: "order", privilege: "display")
      expect(permission_set).not_to be_valid
      expect(permission_set.errors[:set]).to include("can't be blank")
    end

    it "is invalid without a privilege" do
      permission_set = described_class.new(name: "OrderDisplay", set: "Spree::PermissionSet::OrderDisplay", category: "display")
      expect(permission_set).not_to be_valid
      expect(permission_set.errors[:privilege]).to include("can't be blank")
    end

    it "is invalid without a category" do
      permission_set = described_class.new(name: "OrderDisplay", set: "Spree::PermissionSet::OrderDisplay", privilege: "order")
      expect(permission_set).not_to be_valid
      expect(permission_set.errors[:category]).to include("can't be blank")
    end
  end

  describe "scopes" do
    let!(:display_permission) { described_class.create(name: "OrderDisplay", set: "Spree::PermissionSet::OrderDisplay", category: "order", privilege: "display") }
    let!(:management_permission) { described_class.create(name: "OrderManagement", set: "Spree::PermissionSet::OrderManagement", category: "order", privilege: "management") }
    let!(:other_permission) { described_class.create(name: "Shipping", set: "Spree::PermissionSet::Shipping", category: "shipping", privilege: "other") }

    it "returns permission sets with privilege: display for display_permissions scope" do
      expect(Spree::PermissionSet.display_permissions).to include(display_permission)
      expect(Spree::PermissionSet.display_permissions).not_to include(management_permission, other_permission)
    end

    it "returns permission sets with privilege: management for management_permissions scope" do
      expect(Spree::PermissionSet.management_permissions).to include(management_permission)
      expect(Spree::PermissionSet.management_permissions).not_to include(display_permission, other_permission)
    end

    it "returns permission sets with privilege: other for other_permissions scope" do
      expect(Spree::PermissionSet.management_permissions).to include(management_permission)
      expect(Spree::PermissionSet.management_permissions).not_to include(display_permission, other_permission)
    end
  end
end
