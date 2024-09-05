# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::RolePermission, type: :model do
  describe "associations" do
    it "belongs to a role" do
      association = described_class.reflect_on_association(:role)
      expect(association.macro).to eq(:belongs_to)
    end

    it "belongs to a permission_set" do
      association = described_class.reflect_on_association(:permission_set)
      expect(association.macro).to eq(:belongs_to)
    end
  end
end
