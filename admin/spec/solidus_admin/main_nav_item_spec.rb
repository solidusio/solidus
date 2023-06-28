# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::MainNavItem do
  describe "#with_child" do
    it "returns a new instance" do
      item = described_class.new(key: "foo", position: 1)

      result = item.with_child(key: "bar", position: 1)

      aggregate_failures do
        expect(result).to be_a(described_class)
        expect(result).not_to be(item)
      end
    end

    it "keeps the item attributes" do
      item = described_class.new(key: "foo", position: 1, icon: "icon", top_level: true)

      result = item.with_child(key: "bar", position: 1)

      aggregate_failures do
        expect(result.key).to eq("foo")
        expect(result.position).to eq(1)
        expect(result.icon).to eq("icon")
        expect(result.top_level).to be(true)
      end
    end

    it "adds a child to the item" do
      item = described_class.new(
        key: "foo", position: 1, children: [described_class.new(key: "bar", position: 1)]
      )

      result = item.with_child(key: "baz", position: 1)

      expect(result.children.count).to be(2)
    end

    it "sets child as not top level" do
      item = described_class.new(key: "foo", position: 1)

      result = item.with_child(key: "bar", position: 1)

      expect(result.children.first.top_level).to be(false)
    end
  end

  describe "#children?" do
    it "returns false when there are no children" do
      item = described_class.new(key: "foo", position: 1)

      expect(item.children?).to be(false)
    end

    it "returns true when there are children" do
      item = described_class.new(
        key: "foo", position: 1, children: [described_class.new(key: "bar", position: 1)]
      )

      expect(item.children?).to be(true)
    end
  end
end
