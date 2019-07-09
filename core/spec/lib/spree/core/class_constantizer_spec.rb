# frozen_string_literal: true

require 'spec_helper'
require 'spree/core/class_constantizer'

module ClassConstantizerTest
  ClassA = Class.new
  ClassB = Class.new

  def self.reload
    [:ClassA, :ClassB].each do |klass|
      remove_const(klass)
      const_set(klass, Class.new)
    end
  end
end

RSpec.describe Spree::Core::ClassConstantizer::Set do
  let(:set) { described_class.new }

  describe "#concat" do
    it "can add one item" do
      set.concat(['ClassConstantizerTest::ClassA'])
      expect(set).to include(ClassConstantizerTest::ClassA)
    end

    it "can add two items" do
      set.concat(['ClassConstantizerTest::ClassA', ClassConstantizerTest::ClassB])
      expect(set).to include(ClassConstantizerTest::ClassA)
      expect(set).to include(ClassConstantizerTest::ClassB)
    end

    it "returns itself" do
      expect(set.concat(['String'])).to eql(set)
    end
  end

  describe "<<" do
    it "can add by string" do
      set << "ClassConstantizerTest::ClassA"
      expect(set).to include(ClassConstantizerTest::ClassA)
    end

    it "can add by class" do
      set << ClassConstantizerTest::ClassA
      expect(set).to include(ClassConstantizerTest::ClassA)
    end

    describe "class redefinition" do
      shared_examples "working code reloading" do
        it "works with a class" do
          original = ClassConstantizerTest::ClassA

          ClassConstantizerTest.reload

          # Sanity check
          expect(original).not_to eq(ClassConstantizerTest::ClassA)

          expect(set).to include(ClassConstantizerTest::ClassA)
          expect(set).to_not include(original)
        end
      end

      context "with a class" do
        before { set << ClassConstantizerTest::ClassA }
        it_should_behave_like "working code reloading"
      end

      context "with a string" do
        before { set << "ClassConstantizerTest::ClassA" }
        it_should_behave_like "working code reloading"
      end
    end
  end

  describe "#delete" do
    before do
      set << ClassConstantizerTest::ClassA
    end

    it "can delete by string" do
      set.delete "ClassConstantizerTest::ClassA"
      expect(set).not_to include(ClassConstantizerTest::ClassA)
    end

    it "can delete by class" do
      set.delete ClassConstantizerTest::ClassA
      expect(set).not_to include(ClassConstantizerTest::ClassA)
    end
  end
end
