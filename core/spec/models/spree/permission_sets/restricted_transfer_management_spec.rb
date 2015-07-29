require 'spec_helper'

describe Spree::PermissionSets::RestrictedTransferManagement do
  let(:ability) { Spree::Ability.new(user) }

  subject { ability }

  let!(:source_location) { create :stock_location }
  let!(:destination_location) { create :stock_location }

  # This has the side effect of creating a stock item for each stock location above,
  # which is what we actually want.
  let!(:variant) { create :variant }

  let(:source_stock_item) { source_location.stock_items.first }
  let(:destination_stock_item) { destination_location.stock_items.first }

  let(:transfer_with_source) { create :stock_transfer, source_location: source_location }
  let(:transfer_with_destination) { create :stock_transfer, source_location: destination_location  }
  let(:transfer_with_source_and_destination) do
    create :stock_transfer, source_location: source_location, destination_location: destination_location
  end

  let(:transfer_amount) { 1 }
  let(:source_transfer_item) do
    transfer_with_source.transfer_items.create(variant: variant, expected_quantity: transfer_amount)
  end
  let(:destination_transfer_item) do
    transfer_with_destination.transfer_items.create(variant: variant, expected_quantity: transfer_amount)
  end
  let(:source_and_destination_transfer_item) do
    transfer_with_source_and_destination.transfer_items.create(variant: variant, expected_quantity: transfer_amount)
  end

  context "when activated" do
    let(:user) { create :user, stock_locations: stock_locations }
    let(:stock_locations) {[]}

    before do
      user.stock_locations = stock_locations
      # When creating transfer_items for a stock transfer, stock items must have a count on hand
      # with an amount that would allow a transfer item to pass validations (meaning the count on hand has to be equal
      # to the expected_quantity for the transfer)
      variant.stock_items.update_all count_on_hand: transfer_amount

      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:display, Spree::StockItem) }
    it { is_expected.to be_able_to(:display, Spree::StockTransfer) }
    it { is_expected.to be_able_to(:admin, Spree::StockItem) }
    it { is_expected.to be_able_to(:admin, Spree::StockTransfer) }

    context "when the user is associated with one of the locations" do
      let(:stock_locations) {[source_location]}

      it { is_expected.to be_able_to(:update, source_stock_item) }
      it { is_expected.not_to be_able_to(:update, destination_stock_item) }

      it { is_expected.to be_able_to(:transfer, source_location) }
      it { is_expected.not_to be_able_to(:transfer, destination_location) }

      it { is_expected.to be_able_to(:manage, transfer_with_source) }
      it { is_expected.not_to be_able_to(:manage, transfer_with_destination) }
      it { is_expected.not_to be_able_to(:manage, transfer_with_source_and_destination) }

      it { is_expected.to be_able_to(:manage, source_transfer_item) }
      it { is_expected.not_to be_able_to(:manage, destination_transfer_item) }
      it { is_expected.not_to be_able_to(:manage, source_and_destination_transfer_item) }
    end


    context "when the user is associated with both locations" do
      let(:stock_locations) {[source_location, destination_location]}

      it { is_expected.to be_able_to(:update, source_stock_item) }
      it { is_expected.to be_able_to(:update, destination_stock_item) }

      it { is_expected.to be_able_to(:transfer, source_location) }
      it { is_expected.to be_able_to(:transfer, destination_location) }

      it { is_expected.to be_able_to(:manage, transfer_with_source) }
      it { is_expected.to be_able_to(:manage, transfer_with_destination) }
      it { is_expected.to be_able_to(:manage, transfer_with_source_and_destination) }

      it { is_expected.to be_able_to(:manage, source_transfer_item) }
      it { is_expected.to be_able_to(:manage, destination_transfer_item) }
      it { is_expected.to be_able_to(:manage, source_and_destination_transfer_item) }
    end

    context "when the user is associated with neither location" do
      let(:stock_locations) {[]}

      it { is_expected.not_to be_able_to(:update, source_stock_item) }
      it { is_expected.not_to be_able_to(:update, destination_stock_item) }

      it { is_expected.not_to be_able_to(:transfer, source_location) }
      it { is_expected.not_to be_able_to(:transfer, destination_location) }

      it { is_expected.not_to be_able_to(:manage, transfer_with_source) }
      it { is_expected.not_to be_able_to(:manage, transfer_with_destination) }
      it { is_expected.not_to be_able_to(:manage, transfer_with_source_and_destination) }

      it { is_expected.not_to be_able_to(:manage, source_transfer_item) }
      it { is_expected.not_to be_able_to(:manage, destination_transfer_item) }
      it { is_expected.not_to be_able_to(:manage, source_and_destination_transfer_item) }
    end
  end

  context "when not activated" do
    let(:user) { create :user }

    it { is_expected.not_to be_able_to(:display, Spree::StockTransfer) }
    it { is_expected.not_to be_able_to(:admin, Spree::StockItem) }
    it { is_expected.not_to be_able_to(:admin, Spree::StockTransfer) }

    it { is_expected.not_to be_able_to(:update, source_stock_item) }
    it { is_expected.not_to be_able_to(:update, destination_stock_item) }

    it { is_expected.not_to be_able_to(:transfer, source_location) }
    it { is_expected.not_to be_able_to(:transfer, destination_location) }

    it { is_expected.not_to be_able_to(:manage, transfer_with_source) }
    it { is_expected.not_to be_able_to(:manage, transfer_with_destination) }
    it { is_expected.not_to be_able_to(:manage, transfer_with_source_and_destination) }

    it { is_expected.not_to be_able_to(:manage, source_transfer_item) }
    it { is_expected.not_to be_able_to(:manage, destination_transfer_item) }
    it { is_expected.not_to be_able_to(:manage, source_and_destination_transfer_item) }
  end
end

