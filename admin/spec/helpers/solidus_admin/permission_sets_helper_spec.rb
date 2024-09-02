# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::PermissionSetsHelper, :helper do
  describe "#organize_permissions" do
    let(:view_label) { "View" }
    let(:edit_label) { "Edit" }

    let(:display_permission) do
      Spree::PermissionSet.create!(
        category: "sample_privilege",
        privilege: "display",
        name: "SampleDisplay",
        set: "Spree::PermissionSet::SampleDisplay"
      )
    end

    let(:management_permission) do
      Spree::PermissionSet.create!(
        category: "sample_privilege",
        privilege: "management",
        name: "SampleManagement",
        set: "Spree::PermissionSet::SampleManagement"
      )
    end

    let(:other_permission) do
      Spree::PermissionSet.create!(
        category: "sample_privilege",
        privilege: "other",
        name: "SampleOther",
        set: "Spree::PermissionSet::SampleOther"
      )
    end

    let(:permission_sets) { [display_permission, management_permission, other_permission] }

    context "when permission_sets are provided" do
      it "organizes permissions into the correct categories with labels and IDs" do
        result = helper.organize_permissions(
          permission_sets: permission_sets,
          view_label: view_label,
          edit_label: edit_label
        )

        expect(result[:sample_privilege]).to contain_exactly(
          hash_including(label: view_label, id: display_permission.id),
          hash_including(label: edit_label, id: management_permission.id)
        )

        expect(result[:other]).to contain_exactly(
          hash_including(label: "SampleOther", id: other_permission.id)
        )
      end

      it "creates a hash with keys for each privilege and other" do
        result = helper.organize_permissions(
          permission_sets: permission_sets,
          view_label: view_label,
          edit_label: edit_label
        )

        expect(result.keys).to include(:sample_privilege, :other)
      end
    end

    context "when permission_sets are empty" do
      let(:permission_sets) { [] }

      it "returns an empty hash" do
        result = helper.organize_permissions(
          permission_sets: permission_sets,
          view_label: view_label,
          edit_label: edit_label
        )

        expect(result).to eq({})
      end
    end

    context "when permission_sets are nil" do
      let(:permission_sets) { nil }

      it "returns an empty hash" do
        result = helper.organize_permissions(
          permission_sets: permission_sets,
          view_label: view_label,
          edit_label: edit_label
        )

        expect(result).to eq({})
      end
    end
  end
end
