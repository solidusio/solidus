# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::PermissionSets::Base do
  let(:ability) { Spree::Ability.new nil }
  subject { described_class.new(ability).activate! }

  describe "activate!" do
    it "raises a not implemented error" do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end

  context "when the subclass does not define a privilege" do
    # Define a subclass that does not override privilege
    before do
      stub_const("Spree::PermissionSets::ExampleSubclass", Class.new(Spree::PermissionSets::Base))
    end

    it "raises a NotImplementedError" do
      expect { Spree::PermissionSets::ExampleSubclass.privilege }.to raise_error(NotImplementedError, /must define a privilege/)
    end
  end

  context "when the subclass does not define a category" do
    # Define a subclass that does not override category
    before do
      stub_const("Spree::PermissionSets::ExampleSubclass", Class.new(Spree::PermissionSets::Base))
    end

    it "raises a NotImplementedError" do
      expect { Spree::PermissionSets::ExampleSubclass.category }.to raise_error(NotImplementedError, /must define a category/)
    end
  end

  context "when the subclass defines privilege and category correctly" do
    # Define a subclass that correctly overrides privilege and category
    before do
      stub_const("Spree::PermissionSets::ValidSubclass", Class.new(Spree::PermissionSets::Base) do
        def self.privilege
          :valid_privilege
        end

        def self.category
          :valid_category
        end
      end)
    end

    it "returns the correct privilege" do
      expect(Spree::PermissionSets::ValidSubclass.privilege).to eq(:valid_privilege)
    end

    it "returns the correct category" do
      expect(Spree::PermissionSets::ValidSubclass.category).to eq(:valid_category)
    end
  end
end
