# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::MainNavItem do
  def url_helpers(solidus_admin: {}, spree: {})
    double(
      solidus_admin: double(**solidus_admin),
      spree: double(**spree)
    )
  end

  describe "#children?" do
    it "returns false when there are no children" do
      item = described_class.new(key: "foo", route: :foo_path, position: 1)

      expect(item.children?).to be(false)
    end

    it "returns true when there are children" do
      item = described_class.new(
        key: "foo", route: :foo_path, position: 1, children: [described_class.new(key: "bar", route: :bar_path, position: 1)]
      )

      expect(item.children?).to be(true)
    end
  end

  describe "#path" do
    context "when the route is a symbol" do
      it "calls that method on the solidus_admin url_helpers" do
        item = described_class.new(key: "foo", route: :foo_path, position: 1)
        url_helpers = url_helpers(solidus_admin: { foo_path: "/foo" })

        expect(item.path(url_helpers)).to eq("/foo")
      end
    end

    context "when the route is a Proc" do
      it "evaluates it in the url helpers context" do
        item = described_class.new(key: "foo", route: -> { solidus_admin.foo_path }, position: 1)
        url_helpers = url_helpers(solidus_admin: { foo_path: "/foo" })

        expect(item.path(url_helpers)).to eq("/foo")
      end
    end
  end

  describe "#current?" do
    it "returns true when the path matches the current request path" do
      item = described_class.new(key: "foo", route: :foo_path, position: 1)
      url_helpers = url_helpers(solidus_admin: { foo_path: "/foo" })

      expect(
        item.current?(url_helpers, "/foo")
      ).to be(true)
    end

    it "returns true when the path matches the current request base path" do
      item = described_class.new(key: "foo", route: :foo_path, position: 1)
      url_helpers = url_helpers(solidus_admin: { foo_path: "/foo" })

      expect(
        item.current?(url_helpers, "/foo?bar=baz")
      ).to be(true)
    end

    it "returns false when the path does not match the current request base path" do
      item = described_class.new(key: "foo", route: :foo_path, position: 1)
      url_helpers = url_helpers(solidus_admin: { foo_path: "/foo" })

      expect(
        item.current?(url_helpers, "/bar")
      ).to be(false)
    end
  end

  describe "#active?" do
    it "returns true when it's the current item" do
      item = described_class.new(key: "foo", route: :foo_path, position: 1)
      url_helpers = url_helpers(solidus_admin: { foo_path: "/foo" })

      expect(
        item.active?(url_helpers, "/foo")
      ).to be(true)
    end

    it "returns true when one of its children is active" do
      item = described_class.new(
        key: "foo", route: :foo_path, position: 1, children: [described_class.new(key: "bar", route: :bar_path, position: 1)]
      )
      url_helpers = url_helpers(solidus_admin: { foo_path: "/foo", bar_path: "/bar" })

      expect(
        item.active?(url_helpers, "/bar")
      ).to be(true)
    end

    it "returns false otherwise" do
      item = described_class.new(key: "foo", route: :foo_path, position: 1)
      url_helpers = url_helpers(solidus_admin: { foo_path: "/foo" })

      expect(
        item.active?(url_helpers, "/bar")
      ).to be(false)
    end
  end
end
