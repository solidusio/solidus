# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Base do
  before(:all) do
    class CreatePrefTest < ActiveRecord::Migration[4.2]
      def self.up
        create_table :pref_tests do |item|
          item.string :col
          item.text :preferences
        end
      end

      def self.down
        drop_table :pref_tests
      end
    end

    @migration_verbosity = ActiveRecord::Migration[4.2].verbose
    ActiveRecord::Migration[4.2].verbose = false
    CreatePrefTest.migrate(:up)
  end

  after(:all) do
    CreatePrefTest.migrate(:down)
    ActiveRecord::Migration[4.2].verbose = @migration_verbosity
  end

  context "with a class that has a preference column but does not explicitly serialize" do
    before :all do
      class PrefTestWithoutSerialization < Spree::Base
        self.table_name = :pref_tests
      end
    end

    before(:each) do
      allow(Spree::Deprecation).to receive(:warn).
        with(/^PrefTestWithoutSerialization has a `preferences` column, but does not explicitly \(de\)serialize this column.*/m, any_args)
    end

    after(:all) do
      Object.send(:remove_const, :PrefTestWithoutSerialization)
    end

    it "returns a Hash nevertheless" do
      instance = PrefTestWithoutSerialization.new
      expect(instance.preferences).to be_a(Hash)
    end

    it "returns a Hash when there's already values in the table" do
      ActiveRecord::Base.connection.execute("INSERT INTO pref_tests (col, preferences) VALUES ('test', '---\n:percent: 20')")
      instance = PrefTestWithoutSerialization.first
      expect(instance.preferences).to include(percent: 20)
    end

    it "includes the persistable module when calling #preference and sets the preference default" do
      PrefTestWithoutSerialization.preference :percentage, :number, default: 5
      expect(PrefTestWithoutSerialization.new.preferences).to eq(percentage: 5)
    end
  end
end
