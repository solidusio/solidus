# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Role, type: :model do
  describe "associations" do
    it "has many role_users" do
      association = described_class.reflect_on_association(:role_users)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it "has many users through role_users" do
      association = described_class.reflect_on_association(:users)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:through]).to eq(:role_users)
    end

    it "has many role_permissions" do
      association = described_class.reflect_on_association(:role_permissions)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it "has many permission_sets through role_permissions" do
      association = described_class.reflect_on_association(:permission_sets)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:through]).to eq(:role_permissions)
    end
  end

  describe "validations" do
    it "is invalid without a name" do
      role = described_class.new
      expect(role).not_to be_valid
      expect(role.errors[:name]).to include("can't be blank")
    end

    it "validates uniqueness of name" do
      described_class.create!(name: "admin")
      duplicate_role = described_class.new(name: "admin")
      expect(duplicate_role).not_to be_valid
      expect(duplicate_role.errors[:name]).to include("has already been taken")
    end
  end

  describe "#admin?" do
    it "returns true if the role name is 'admin'" do
      role = described_class.new(name: "admin")
      expect(role.admin?).to be true
    end

    it "returns false if the role name is not 'admin'" do
      role = described_class.new(name: "user")
      expect(role.admin?).to be false
    end
  end

  describe "#destroy" do
    let(:role) { create(:role) }
    let(:display_permission) { Spree::PermissionSet.create!(name: "OrderDisplay", set: "Spree::PermissionSet::OrderDisplay", category: "order", privilege: "display") }

    before do
      role.permission_sets << display_permission
      role.save
    end

    it "destroys all associated role permissions" do
      role_permission = role.role_permissions.first

      role.destroy
      aggregate_failures do
        expect { described_class.find(role.id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect { Spree::RolePermission.find(role_permission.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
