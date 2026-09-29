# frozen_string_literal: true

require "rails_helper"
require "spree/testing_support/shared_examples/working_factory"

RSpec.describe "admin user factory" do
  let(:factory_class) { Spree.admin_user_class }

  describe "admin user" do
    let(:factory) { :admin_user }

    it_behaves_like "a working factory"

    it "has the admin role" do
      expect(create(factory).spree_roles.map(&:name)).to include("admin")
    end
  end
end
