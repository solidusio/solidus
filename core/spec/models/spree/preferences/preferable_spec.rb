# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Preferences::Preferable, type: :model do
  before :all do
    class A
      include Spree::Preferences::Preferable
      attr_reader :id

      def initialize
        @id = rand(999)
      end

      def preferences
        @preferences ||= default_preferences
      end

      preference :color, :string, default: 'green'
    end

    class B < A
      preference :flavor, :string
    end
  end

  before :each do
    @a = A.new
    @b = B.new
  end

  describe "preference definitions" do
    it "parent should not see child definitions" do
      expect(@a.has_preference?(:color)).to be true
      expect(@a.has_preference?(:flavor)).not_to be true
    end

    it "child should have parent and own definitions" do
      expect(@b.has_preference?(:color)).to be true
      expect(@b.has_preference?(:flavor)).to be true
    end

    it "instances have defaults" do
      expect(@a.preferred_color).to eq 'green'
      expect(@b.preferred_color).to eq 'green'
      expect(@b.preferred_flavor).to be_nil
    end

    it "can be asked if it has a preference definition" do
      expect(@a.has_preference?(:color)).to be true
      expect(@a.has_preference?(:bad)).to be false
    end

    it "can be asked and raises" do
      expect {
        @a.has_preference! :flavor
      }.to raise_error(NoMethodError, "flavor preference not defined")
    end

    it "has a type" do
      expect(@a.preferred_color_type).to eq :string
      expect(@a.preference_type(:color)).to eq :string
    end

    it "has a default" do
      expect(@a.preferred_color_default).to eq 'green'
      expect(@a.preference_default(:color)).to eq 'green'
    end

    it "raises if not defined" do
      expect {
        @a.get_preference :flavor
      }.to raise_error(NoMethodError, "flavor preference not defined")
    end
  end

  describe "preference access" do
    it "handles ghost methods for preferences" do
      @a.preferred_color = 'blue'
      expect(@a.preferred_color).to eq 'blue'
    end

    it "parent and child instances have their own prefs" do
      @a.preferred_color = 'red'
      @b.preferred_color = 'blue'

      expect(@a.preferred_color).to eq 'red'
      expect(@b.preferred_color).to eq 'blue'
    end

    it "raises when preference not defined" do
      expect {
        @a.set_preference(:bad, :bone)
      }.to raise_exception(NoMethodError, "bad preference not defined")
    end

    it "builds a hash of preferences" do
      @b.preferred_flavor = :strawberry
      expect(@b.preferences[:flavor]).to eq 'strawberry'
      expect(@b.preferences[:color]).to eq 'green' # default from A
    end

    it "builds a hash of preference defaults" do
      expect(@b.default_preferences).to eq({
        flavor: nil,
        color: 'green'
      })
    end

    describe '#admin_form_preference_names' do
      subject do
        ComplexPreferableClass.new.admin_form_preference_names
      end

      before do
        class ComplexPreferableClass
          include Spree::Preferences::Preferable
          preference :name, :string
          preference :password, :password
          preference :mapping, :hash
          preference :recipients, :array
        end
      end

      it "returns an array of preference names excluding preferences not presentable as form field" do
        is_expected.to contain_exactly(:name, :password)
      end

      context 'with overwritten allowed_admin_form_preference_types class method' do
        subject do
          ComplexOverwrittenPreferableClass.new.admin_form_preference_names
        end

        before do
          class ComplexOverwrittenPreferableClass
            include Spree::Preferences::Preferable
            preference :name, :string
            preference :password, :password
            preference :mapping, :hash
            preference :recipients, :array

            def self.allowed_admin_form_preference_types
              %i(string password hash array)
            end
          end
        end

        it 'returns these types instead' do
          is_expected.to contain_exactly(:name, :password, :mapping, :recipients)
        end
      end
    end

    context "converts integer preferences to integer values" do
      before do
        A.preference :is_integer, :integer
      end

      it "with strings" do
        @a.set_preference(:is_integer, '3')
        expect(@a.preferences[:is_integer]).to eq(3)

        @a.set_preference(:is_integer, '')
        expect(@a.preferences[:is_integer]).to eq(0)
      end

      it 'does not convert if value is nil' do
        @a.set_preference(:is_integer, nil)
        expect(@a.preferences[:is_integer]).to be_nil
      end
    end

    context "converts decimal preferences to BigDecimal values" do
      before do
        A.preference :if_decimal, :decimal
      end

      it "returns a BigDecimal" do
        @a.set_preference(:if_decimal, 3.3)
        expect(@a.preferences[:if_decimal].class).to eq(BigDecimal)
      end

      it "with strings" do
        @a.set_preference(:if_decimal, '3.3')
        expect(@a.preferences[:if_decimal]).to eq(3.3)

        @a.set_preference(:if_decimal, '')
        expect(@a.preferences[:if_decimal]).to eq(0.0)
      end
    end

    context "converts boolean preferences to boolean values" do
      before do
        A.preference :is_boolean, :boolean, default: true
      end

      it "with strings" do
        @a.set_preference(:is_boolean, '0')
        expect(@a.preferences[:is_boolean]).to be false
        @a.set_preference(:is_boolean, 'f')
        expect(@a.preferences[:is_boolean]).to be false
        @a.set_preference(:is_boolean, 't')
        expect(@a.preferences[:is_boolean]).to be true
      end

      it "with integers" do
        @a.set_preference(:is_boolean, 0)
        expect(@a.preferences[:is_boolean]).to be false
        @a.set_preference(:is_boolean, 1)
        expect(@a.preferences[:is_boolean]).to be true
      end

      it "with an empty string" do
        @a.set_preference(:is_boolean, '')
        expect(@a.preferences[:is_boolean]).to be false
      end

      it "with an empty hash" do
        @a.set_preference(:is_boolean, [])
        expect(@a.preferences[:is_boolean]).to be false
      end
    end

    context "converts array preferences to array values" do
      before do
        A.preference :is_array, :array, default: []
      end

      it "with arrays" do
        @a.set_preference(:is_array, [])
        expect(@a.preferences[:is_array]).to eq []
      end
    end

    context "converts hash preferences to hash values" do
      before do
        A.preference :is_hash, :hash, default: {}
      end

      it "with hash" do
        @a.set_preference(:is_hash, {})
        expect(@a.preferences[:is_hash]).to be_is_a(Hash)
      end

      it "with hash and keys are integers" do
        @a.set_preference(:is_hash, { 1 => 2, 3 => 4 })
        expect(@a.preferences[:is_hash]).to eql({ 1 => 2, 3 => 4 })
      end
    end

    context "converts any preferences to any values" do
      before do
        A.preference :product_ids, :any, default: []
        A.preference :product_attributes, :any, default: {}
      end

      it "with array" do
        expect(@a.preferences[:product_ids]).to eq([])
        @a.set_preference(:product_ids, [1, 2])
        expect(@a.preferences[:product_ids]).to eq([1, 2])
      end

      it "with hash" do
        expect(@a.preferences[:product_attributes]).to eq({})
        @a.set_preference(:product_attributes, { id: 1, name: 2 })
        expect(@a.preferences[:product_attributes]).to eq({ id: 1, name: 2 })
      end
    end
  end

  describe "persisted preferables" do
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

      class PrefTest < Spree::Base
        preference :pref_test_pref, :string, default: 'abc'
        preference :pref_test_any, :any, default: []
      end
    end

    after(:all) do
      CreatePrefTest.migrate(:down)
      ActiveRecord::Migration[4.2].verbose = @migration_verbosity
    end

    before(:each) do
      @pt = PrefTest.create
    end

    describe "pending preferences for new activerecord objects" do
      it "saves preferences after record is saved" do
        pr = PrefTest.new
        pr.set_preference(:pref_test_pref, 'XXX')
        expect(pr.get_preference(:pref_test_pref)).to eq('XXX')
        pr.save!
        expect(pr.get_preference(:pref_test_pref)).to eq('XXX')
      end

      it "saves preferences for serialized object" do
        pr = PrefTest.new
        pr.set_preference(:pref_test_any, [1, 2])
        expect(pr.get_preference(:pref_test_any)).to eq([1, 2])
        pr.save!
        expect(pr.get_preference(:pref_test_any)).to eq([1, 2])
      end
    end

    it "clear preferences when record is deleted" do
      @pt.save!
      @pt.preferred_pref_test_pref = 'lmn'
      @pt.save!
      @pt.destroy
      @pt1 = PrefTest.new(col: 'aaaa')
      @pt1.id = @pt.id
      @pt1.save!
      expect(@pt1.get_preference(:pref_test_pref)).to eq('abc')
    end
  end
end
