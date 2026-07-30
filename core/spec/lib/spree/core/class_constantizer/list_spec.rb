# frozen_string_literal: true

require "spec_helper"
require "spree/core/class_constantizer/list"

module ClassConstantizerListTest
  ClassA = Class.new
  ClassB = Class.new
  ClassC = Class.new

  def self.reload
    [:ClassA, :ClassB, :ClassC].each do |klass|
      remove_const(klass)
      const_set(klass, Class.new)
    end
  end
end

RSpec.describe Spree::Core::ClassConstantizer::List do
  let(:list) { described_class.new }

  describe "#<<" do
    it "can add by string" do
      list << "ClassConstantizerListTest::ClassA"
      expect(list.to_a).to eq([ClassConstantizerListTest::ClassA])
    end

    it "can add by class" do
      list << ClassConstantizerListTest::ClassA
      expect(list.to_a).to eq([ClassConstantizerListTest::ClassA])
    end

    it "preserves insertion order" do
      list << ClassConstantizerListTest::ClassA
      list << ClassConstantizerListTest::ClassB
      list << ClassConstantizerListTest::ClassC
      expect(list.to_a).to eq([
        ClassConstantizerListTest::ClassA,
        ClassConstantizerListTest::ClassB,
        ClassConstantizerListTest::ClassC
      ])
    end

    it "allows duplicates" do
      list << ClassConstantizerListTest::ClassA
      list << ClassConstantizerListTest::ClassA
      expect(list.count).to eq(2)
    end

    describe "class redefinition" do
      shared_examples "working code reloading" do
        it "resolves to the reloaded class on iteration" do
          original = ClassConstantizerListTest::ClassA

          ClassConstantizerListTest.reload

          # Sanity check
          expect(original).not_to eq(ClassConstantizerListTest::ClassA)

          expect(list.to_a).to eq([ClassConstantizerListTest::ClassA])
          expect(list.to_a).not_to include(original)
        end
      end

      context "with a class" do
        before { list << ClassConstantizerListTest::ClassA }

        include_examples "working code reloading"
      end

      context "with a string" do
        before { list << "ClassConstantizerListTest::ClassA" }

        include_examples "working code reloading"
      end
    end
  end

  describe "#concat" do
    it "can add one item" do
      list.concat(["ClassConstantizerListTest::ClassA"])
      expect(list.to_a).to eq([ClassConstantizerListTest::ClassA])
    end

    it "can add many items, preserving order" do
      list.concat([
        "ClassConstantizerListTest::ClassA",
        ClassConstantizerListTest::ClassB,
        ClassConstantizerListTest::ClassC
      ])
      expect(list.to_a).to eq([
        ClassConstantizerListTest::ClassA,
        ClassConstantizerListTest::ClassB,
        ClassConstantizerListTest::ClassC
      ])
    end

    it "returns itself" do
      expect(list.concat(["String"])).to eql(list)
    end
  end

  describe "#each" do
    it "yields each class" do
      list << ClassConstantizerListTest::ClassA
      list << ClassConstantizerListTest::ClassB

      yielded = []
      list.each { |klass| yielded << klass }

      expect(yielded).to eq([
        ClassConstantizerListTest::ClassA,
        ClassConstantizerListTest::ClassB
      ])
    end

    it "makes the list Enumerable" do
      list << ClassConstantizerListTest::ClassA
      list << ClassConstantizerListTest::ClassB

      expect(list.count).to eq(2)
      expect(list.first).to eq(ClassConstantizerListTest::ClassA)
      expect(list.map(&:name)).to eq([
        "ClassConstantizerListTest::ClassA",
        "ClassConstantizerListTest::ClassB"
      ])
    end
  end

  describe "#insert_before" do
    before do
      list << ClassConstantizerListTest::ClassA
      list << ClassConstantizerListTest::ClassC
    end

    it "inserts before a class anchor" do
      list.insert_before(ClassConstantizerListTest::ClassC, ClassConstantizerListTest::ClassB)
      expect(list.to_a).to eq([
        ClassConstantizerListTest::ClassA,
        ClassConstantizerListTest::ClassB,
        ClassConstantizerListTest::ClassC
      ])
    end

    it "inserts before a string anchor" do
      list.insert_before("ClassConstantizerListTest::ClassC", "ClassConstantizerListTest::ClassB")
      expect(list.to_a).to eq([
        ClassConstantizerListTest::ClassA,
        ClassConstantizerListTest::ClassB,
        ClassConstantizerListTest::ClassC
      ])
    end

    it "inserts multiple entries, preserving their order" do
      stub_const("ClassConstantizerListTest::ClassX", Class.new)
      stub_const("ClassConstantizerListTest::ClassY", Class.new)

      list.insert_before(
        ClassConstantizerListTest::ClassC,
        ClassConstantizerListTest::ClassX,
        ClassConstantizerListTest::ClassY
      )
      expect(list.to_a).to eq([
        ClassConstantizerListTest::ClassA,
        ClassConstantizerListTest::ClassX,
        ClassConstantizerListTest::ClassY,
        ClassConstantizerListTest::ClassC
      ])
    end

    it "inserts at the head when the anchor is first" do
      list.insert_before(ClassConstantizerListTest::ClassA, ClassConstantizerListTest::ClassB)
      expect(list.to_a).to eq([
        ClassConstantizerListTest::ClassB,
        ClassConstantizerListTest::ClassA,
        ClassConstantizerListTest::ClassC
      ])
    end

    it "raises ArgumentError when the anchor is not found" do
      expect {
        list.insert_before("ClassConstantizerListTest::Missing", "String")
      }.to raise_error(ArgumentError, /ClassConstantizerListTest::Missing/)
    end

    it "returns self" do
      expect(
        list.insert_before(ClassConstantizerListTest::ClassC, "String")
      ).to eql(list)
    end
  end

  describe "#insert_after" do
    before do
      list << ClassConstantizerListTest::ClassA
      list << ClassConstantizerListTest::ClassC
    end

    it "inserts after a class anchor" do
      list.insert_after(ClassConstantizerListTest::ClassA, ClassConstantizerListTest::ClassB)
      expect(list.to_a).to eq([
        ClassConstantizerListTest::ClassA,
        ClassConstantizerListTest::ClassB,
        ClassConstantizerListTest::ClassC
      ])
    end

    it "inserts after a string anchor" do
      list.insert_after("ClassConstantizerListTest::ClassA", "ClassConstantizerListTest::ClassB")
      expect(list.to_a).to eq([
        ClassConstantizerListTest::ClassA,
        ClassConstantizerListTest::ClassB,
        ClassConstantizerListTest::ClassC
      ])
    end

    it "inserts multiple entries, preserving their order" do
      stub_const("ClassConstantizerListTest::ClassX", Class.new)
      stub_const("ClassConstantizerListTest::ClassY", Class.new)

      list.insert_after(
        ClassConstantizerListTest::ClassA,
        ClassConstantizerListTest::ClassX,
        ClassConstantizerListTest::ClassY
      )
      expect(list.to_a).to eq([
        ClassConstantizerListTest::ClassA,
        ClassConstantizerListTest::ClassX,
        ClassConstantizerListTest::ClassY,
        ClassConstantizerListTest::ClassC
      ])
    end

    it "inserts at the tail when the anchor is last" do
      list.insert_after(ClassConstantizerListTest::ClassC, ClassConstantizerListTest::ClassB)
      expect(list.to_a).to eq([
        ClassConstantizerListTest::ClassA,
        ClassConstantizerListTest::ClassC,
        ClassConstantizerListTest::ClassB
      ])
    end

    it "raises ArgumentError when the anchor is not found" do
      expect {
        list.insert_after("ClassConstantizerListTest::Missing", "String")
      }.to raise_error(ArgumentError, /ClassConstantizerListTest::Missing/)
    end

    it "returns self" do
      expect(
        list.insert_after(ClassConstantizerListTest::ClassA, "String")
      ).to eql(list)
    end
  end

  describe "#delete" do
    before do
      list << ClassConstantizerListTest::ClassA
      list << ClassConstantizerListTest::ClassB
    end

    it "can delete by class" do
      list.delete(ClassConstantizerListTest::ClassA)
      expect(list.to_a).to eq([ClassConstantizerListTest::ClassB])
    end

    it "can delete by string" do
      list.delete("ClassConstantizerListTest::ClassA")
      expect(list.to_a).to eq([ClassConstantizerListTest::ClassB])
    end

    it "is a no-op when the entry is absent" do
      expect { list.delete("ClassConstantizerListTest::Missing") }.not_to change { list.to_a }
    end
  end
end
