# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/configuration/main_nav"

RSpec.describe SolidusAdmin::Configuration::MainNav do
  let(:container) { SolidusAdmin::Container.dup }

  describe "#add" do
    it "registers the item in the container" do
      config = described_class.new(container: container)

      config.add(key: "foo", route: :foo_path, position: 10)

      expect(container.resolve("main_nav.foo")).to be_a(SolidusAdmin::MainNavItem)
    end

    it "adds given children to the item" do
      config = described_class.new(container: container)

      config.add(key: "foo", route: :foo_path, position: 10,
                 children: [{ key: "bar", route: :bar_path, position: 10 }])

      item = container.resolve("main_nav.foo")
      aggregate_failures do
        expect(item.children.count).to be(1)
        expect(item.children.first.key).to eq("bar")
      end
    end

    it "returns the registered item" do
      config = described_class.new(container: container)

      item = config.add(key: "foo", route: :foo_path, position: 10)

      expect(item).to be_a(SolidusAdmin::MainNavItem)
    end

    it "delegates parameters to the item" do
      config = described_class.new(container: container)

      config.add(key: "foo", route: :foo_path, position: 10, icon: "icon")

      item = container.resolve("main_nav.foo")
      aggregate_failures do
        expect(item.key).to eq("foo")
        expect(item.route).to eq(:foo_path)
        expect(item.position).to eq(10)
        expect(item.icon).to eq("icon")
      end
    end
  end
end
