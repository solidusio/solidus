# frozen_string_literal: true

require "rails_helper"
require "spree/core"

RSpec.describe Spree::Core do
  it "loads only the necessary Rails Frameworks" do
    aggregate_failures do
      expect(defined? ActionCable::Engine).to be_falsey
      expect(defined? ActionController::Railtie).to be_truthy
      expect(defined? ActionMailer::Railtie).to be_truthy
      expect(defined? ActionView::Railtie).to be_truthy
      expect(defined? ActiveJob::Railtie).to be_truthy
      expect(defined? ActiveModel::Railtie).to be_truthy
      expect(defined? ActiveRecord::Railtie).to be_truthy
      expect(defined? ActiveStorage::Engine).to be_truthy
      expect(defined? Rails::TestUnit::Railtie).to be_falsey
      expect(defined? Sprockets::Railtie).to be_truthy
    end
  end

  describe ".admin_user_class" do
    around do |example|
      prev_user_class = Spree.user_class_name
      prev_admin_user_class = Spree.admin_user_class_name
      example.run
      Spree.user_class = prev_user_class
      Spree.admin_user_class = prev_admin_user_class == prev_user_class ? nil : prev_admin_user_class
    end

    context "when unset" do
      before do
        Spree.user_class = "Spree::LegacyUser"
        Spree.admin_user_class = nil
      end

      it "falls back to Spree.user_class" do
        expect(Spree.admin_user_class).to eq(Spree::LegacyUser)
      end
    end

    context "when set to a String" do
      before { Spree.admin_user_class = "Spree::LegacyUser" }

      it "constantizes it" do
        expect(Spree.admin_user_class).to eq(Spree::LegacyUser)
      end
    end

    context "when set to a Symbol" do
      before { Spree.admin_user_class = :"Spree::LegacyUser" }

      it "constantizes it" do
        expect(Spree.admin_user_class).to eq(Spree::LegacyUser)
      end
    end

    context "when set to a Class" do
      before { Spree.admin_user_class = Spree::LegacyUser }

      it "raises" do
        expect { Spree.admin_user_class }.to raise_error(
          RuntimeError, "Spree.admin_user_class MUST be a String or Symbol object, not a Class object."
        )
      end
    end
  end

  describe ".admin_user_class_name" do
    around do |example|
      prev_user_class = Spree.user_class_name
      prev_admin_user_class = Spree.admin_user_class_name
      example.run
      Spree.user_class = prev_user_class
      Spree.admin_user_class = prev_admin_user_class == prev_user_class ? nil : prev_admin_user_class
    end

    it "falls back to Spree.user_class_name when unset" do
      Spree.user_class = "Spree::LegacyUser"
      Spree.admin_user_class = nil

      expect(Spree.admin_user_class_name).to eq("Spree::LegacyUser")
    end

    it "returns the configured admin_user_class when set" do
      Spree.admin_user_class = "Spree::AdminUser"

      expect(Spree.admin_user_class_name).to eq("Spree::AdminUser")
    end
  end

  describe ".load_defaults" do
    it "load defaults for all available components" do
      config_instance_builder = -> { Class.new(Spree::Preferences::Configuration).new }
      core = stub_const("Spree::Config", config_instance_builder.call)
      frontend = stub_const("Spree::Frontend::Config", config_instance_builder.call)
      backend = stub_const("Spree::Backend::Config", config_instance_builder.call)
      api = stub_const("Spree::Api::Config", config_instance_builder.call)

      expect(core).to receive(:load_defaults).with(Spree.solidus_version)
      expect(frontend).to receive(:load_defaults).with(Spree.solidus_version)
      expect(backend).to receive(:load_defaults).with(Spree.solidus_version)
      expect(api).to receive(:load_defaults).with(Spree.solidus_version)

      Spree.load_defaults(Spree.solidus_version)
    end
  end

  describe ".has_install_generator_been_run?" do
    let(:rails_paths) do
      Rails::Paths::Root.new("/").tap do |paths|
        paths.add("config/initializers")
        paths["config/initializers"] << File.dirname(__FILE__)
      end
    end

    context "when spree initializer exists" do
      it "returns true" do
        initializer_name = File.basename(__FILE__)

        expect(
          Spree::Core.has_install_generator_been_run?(rails_paths:, initializer_name:, dummy_app_name: "Foo")
        ).to be(true)
      end
    end

    context "when initializer doesn't exist in initializers directory" do
      it "returns false" do
        initializer_name = "xxxxxxxxxxxxxxxxxxxxxx"

        expect(
          Spree::Core.has_install_generator_been_run?(rails_paths:, initializer_name:, dummy_app_name: "Foo")
        ).to be(false)
      end
    end

    context "when running test suite with the dummy application loaded" do
      it "returns true" do
        initializer_name = "xxxxxxxxxxxxxxxxxxxxxx"

        expect(
          Spree::Core.has_install_generator_been_run?(rails_paths:, initializer_name:)
        ).to be(true)
      end
    end
  end
end
