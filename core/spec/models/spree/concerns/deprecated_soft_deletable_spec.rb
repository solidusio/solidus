# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::DeprecatedSoftDeletable do
  let(:hard_deletable_migration) do
    Class.new(ActiveRecord::Migration[5.1]) do
      def change
        create_table(:hard_deletable_items) do |t|
          t.primary_key :id
          t.timestamp :deleted_at
        end
      end
    end
  end

  let(:hard_deletable_item_class) do
    Class.new(Spree::Base) do
      include Spree::SoftDeletable
      include Spree::DeprecatedSoftDeletable

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

  shared_examples "a deprecated soft-deletable method" do |method_names|
    it "emits a deprecation warning" do
      Array(method_names).each do
        expect(Spree.deprecator).to receive(:warn).with(
          a_string_including(method_name.to_s)
        ).at_least(:once)
      end
      subject
    end
  end

  describe "class-level scopes" do
    describe ".kept" do
      subject { hard_deletable_item_class.kept }

      include_examples "a deprecated soft-deletable method", :kept

      it "returns only non-deleted records", :silence_deprecations do
        hard_deletable_item_class.create!
        expect(subject.count).to eq(1)
        hard_deletable_item_class.update(deleted_at: Time.current)
        expect(subject.count).to eq(0)
      end
    end

    describe ".discarded" do
      subject { hard_deletable_item_class.discarded }

      include_examples "a deprecated soft-deletable method", :discarded

      it "returns only deleted records" do
        hard_deletable_item_class.create!(deleted_at: Time.current)
        allow(Spree.deprecator).to receive(:warn)
        expect(subject.count).to eq(1)
      end
    end

    describe ".with_discarded" do
      subject { hard_deletable_item_class.with_discarded }

      include_examples "a deprecated soft-deletable method", :with_discarded

      it "returns all records regardless of deleted_at" do
        hard_deletable_item_class.create!
        hard_deletable_item_class.create!(deleted_at: Time.current)
        allow(Spree.deprecator).to receive(:warn)
        expect(subject.count).to eq(2)
      end
    end
  end

  describe "instance methods" do
    describe "#discard" do
      subject { hard_deletable_item.discard }

      include_examples "a deprecated soft-deletable method", :discard

      it "sets deleted_at" do
        allow(Spree.deprecator).to receive(:warn)
        expect { subject }.to change { hard_deletable_item.deleted_at }.from(nil)
      end
    end

    describe "#discard!" do
      subject { hard_deletable_item.discard! }

      include_examples "a deprecated soft-deletable method", :discard

      it "sets deleted_at" do
        allow(Spree.deprecator).to receive(:warn)
        expect { subject }.to change { hard_deletable_item.deleted_at }.from(nil)
      end
    end

    describe "#undiscard" do
      subject { hard_deletable_item.undiscard }

      before { hard_deletable_item.update!(deleted_at: Time.current) }

      include_examples "a deprecated soft-deletable method", :undiscard

      it "clears deleted_at" do
        allow(Spree.deprecator).to receive(:warn)
        expect { subject }.to change { hard_deletable_item.deleted_at }.to(nil)
      end
    end

    describe "#undiscard!" do
      subject { hard_deletable_item.undiscard! }

      before { hard_deletable_item.update!(deleted_at: Time.current) }

      include_examples "a deprecated soft-deletable method", :undiscard, :discarded

      it "clears deleted_at" do
        allow(Spree.deprecator).to receive(:warn)
        expect { subject }.to change { hard_deletable_item.deleted_at }.to(nil)
      end
    end

    describe "#discarded?" do
      subject { hard_deletable_item.discarded? }

      include_examples "a deprecated soft-deletable method", :discarded?

      it "returns false when deleted_at is nil" do
        allow(Spree.deprecator).to receive(:warn)
        expect(subject).to be(false)
      end

      it "returns true when deleted_at is set" do
        hard_deletable_item.deleted_at = Time.current
        allow(Spree.deprecator).to receive(:warn)
        expect(subject).to be(true)
      end
    end

    describe "#kept?" do
      subject { hard_deletable_item.kept? }

      include_examples "a deprecated soft-deletable method", :kept?

      it "returns true when deleted_at is nil" do
        allow(Spree.deprecator).to receive(:warn)
        expect(subject).to be(true)
      end

      it "returns false when deleted_at is set" do
        hard_deletable_item.deleted_at = Time.current
        allow(Spree.deprecator).to receive(:warn)
        expect(subject).to be(false)
      end
    end
  end
end
