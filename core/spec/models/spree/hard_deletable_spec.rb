# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::HardDeletable do
  let(:hard_deletable_migration) do
    Class.new(ActiveRecord::Migration[5.1]) do
      def change
        create_table(:hard_deletable_items)
      end
    end
  end

  let(:hard_deletable_item_class) do
    Class.new(Spree::Base) do
      include Spree::HardDeletable

      def self.name
        "HardDeletableItem"
      end
    end
  end

  let(:hard_deletable_item) { hard_deletable_item_class.new }

  around do |example|
    hard_deletable_migration.migrate(:up)
    example.run
    hard_deletable_migration.migrate(:down)
  end

  before do
    expect(Spree.deprecator).to receive(:warn)
  end

  describe ".with_discarded" do
    it "is deprecated and returns all" do
      expect(hard_deletable_item_class.with_discarded.to_sql).to eq(hard_deletable_item_class.all.to_sql)
    end
  end

  describe ".kept" do
    it "is deprecated and returns all" do
      expect(hard_deletable_item_class.kept.to_sql).to eq(hard_deletable_item_class.all.to_sql)
    end
  end

  describe ".discarded" do
    it "is deprecated and returns none" do
      expect(hard_deletable_item_class.discarded.to_sql).to eq(hard_deletable_item_class.none.to_sql)
    end
  end

  describe ".discard_all" do
    it "is deprecated and calls #destroy_all" do
      expect(hard_deletable_item_class).to receive(:destroy_all)
      hard_deletable_item_class.discard_all
    end
  end

  describe "#deleted_at" do
    subject { hard_deletable_item.deleted_at }
    it { is_expected.to be nil }
  end

  describe "#discarded?" do
    subject { hard_deletable_item.discarded? }
    it { is_expected.to be false }
  end

  describe "#undiscarded?" do
    subject { hard_deletable_item.undiscarded? }
    it { is_expected.to be true }
  end

  describe "#kept?" do
    subject { hard_deletable_item.kept? }
    it { is_expected.to be true }
  end
end
