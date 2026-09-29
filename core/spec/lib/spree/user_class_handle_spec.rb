# frozen_string_literal: true

require "spec_helper"
require "spree/core"
require "spree/user_class_handle"

RSpec.describe Spree::UserClassHandle do
  describe "#to_s" do
    around do |example|
      @prev_user_class = Spree.user_class_name
      example.run
      Spree.user_class = @prev_user_class
    end

    subject { described_class.new.to_s }

    context "when Spree.user_class is nil" do
      before do
        Spree.user_class = nil
      end

      it "is expected to fail" do
        expect { subject }.to raise_error(RuntimeError, "'Spree.user_class' has not been set yet.")
      end
    end

    context "when Spree.user_class is not nil" do
      before do
        Spree.user_class = "Spree::User"
      end

      it "is expected to return the user class as a string" do
        expect(subject).to eq("::Spree::User")
      end
    end
  end
end

RSpec.describe Spree::AdminUserClassHandle do
  describe "#to_s" do
    around do |example|
      prev_user_class = Spree.user_class_name
      prev_admin_user_class = Spree.admin_user_class_name
      example.run
      Spree.user_class = prev_user_class
      Spree.admin_user_class = prev_admin_user_class == prev_user_class ? nil : prev_admin_user_class
    end

    subject { described_class.new.to_s }

    context "when Spree.admin_user_class is nil" do
      before do
        Spree.user_class = "Spree::User"
        Spree.admin_user_class = nil
      end

      it "falls back to Spree.user_class" do
        expect(subject).to eq("::Spree::User")
      end
    end

    context "when Spree.admin_user_class is set" do
      before do
        Spree.admin_user_class = "Spree::AdminUser"
      end

      it "is expected to return the admin user class as a string" do
        expect(subject).to eq("::Spree::AdminUser")
      end
    end
  end
end

RSpec.describe Spree::ClassProxy do
  describe "#to_s" do
    context "when the block returns nil" do
      subject { described_class.new("Some.setting") { nil }.to_s }

      it "fails with the given setting name" do
        expect { subject }.to raise_error(RuntimeError, "'Some.setting' has not been set yet.")
      end
    end

    context "when the block returns a class name" do
      subject { described_class.new("Some.setting") { "Spree::User" }.to_s }

      it "returns the fully qualified class name" do
        expect(subject).to eq("::Spree::User")
      end
    end
  end
end
