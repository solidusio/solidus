# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusFriendlyPromotions::Conditions::UserRole, type: :model do
  subject { condition }

  let(:condition) { described_class.new(preferred_role_ids: roles_for_condition.map(&:id)) }
  let(:user) { create(:user, spree_roles: roles_for_user) }
  let(:roles_for_condition) { [] }
  let(:roles_for_user) { [] }

  shared_examples "eligibility" do
    context "no roles on condition" do
      let(:roles_for_user) { create_list(:role, 1) }

      it "is not eligible" do
        expect(condition).not_to be_eligible(order)
      end
    end

    context "no roles on user" do
      let(:roles_for_condition) { create_list(:role, 1) }

      it "is not eligible" do
        expect(condition).not_to be_eligible(order)
      end
    end

    context "mismatched roles" do
      let(:roles_for_user) { create_list(:role, 1) }
      let(:roles_for_condition) { create_list(:role, 1) }

      it "is not eligible" do
        expect(condition).not_to be_eligible(order)
      end
    end

    context "matching all roles" do
      let(:roles_for_user) { create_list(:role, 2) }
      let(:roles_for_condition) { roles_for_user }

      it "is eligible" do
        expect(condition).to be_eligible(order)
      end
    end
  end

  describe "#eligible?(order)" do
    context "order with no user" do
      let(:order) { Spree::Order.new }

      it "is not eligible" do
        expect(condition).not_to be_eligible(order)
      end
    end

    context "order with user" do
      let(:order) { Spree::Order.new(user: user) }

      context "with any match policy" do
        before { condition.preferred_match_policy = "any" }

        include_examples "eligibility"

        context "one shared role" do
          let(:shared_role) { create(:role) }
          let(:roles_for_user) { [create(:role), shared_role] }
          let(:roles_for_condition) { [create(:role), shared_role] }

          it "is eligible" do
            expect(condition).to be_eligible(order)
          end
        end
      end

      context "with all match policy" do
        before { condition.preferred_match_policy = "all" }

        include_examples "eligibility"

        context "one shared role" do
          let(:shared_role) { create(:role) }
          let(:roles_for_user) { [create(:role), shared_role] }
          let(:roles_for_condition) { [create(:role), shared_role] }

          it "is not eligible" do
            expect(condition).not_to be_eligible(order)
          end
        end
      end
    end
  end
end
