# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Api::InventoryUnitsController, type: :request do
    let!(:inventory_unit) { create(:inventory_unit) }

    before do
      stub_authentication!
    end

    context "as an admin" do
      sign_in_as_admin!
      let(:variant) { create(:variant) }

      it "gets an inventory unit" do
        get spree.api_inventory_unit_path(inventory_unit)
        expect(json_response['state']).to eq inventory_unit.state
      end

      it "updates an inventory unit" do
        put spree.api_inventory_unit_path(inventory_unit), params: {
          inventory_unit: { variant_id: variant.id }
        }
        expect(json_response['variant_id']).to eq variant.id
      end

      context 'fires state event' do
        it 'if supplied with :fire param' do
          put spree.api_inventory_unit_path(inventory_unit), params: {
            fire: 'ship',
            inventory_unit: { variant_id: variant.id }
          }

          expect(json_response['state']).to eq 'shipped'
        end

        it 'and returns exception if cannot fire' do
          put spree.api_inventory_unit_path(inventory_unit), params: {
            fire: 'return'
          }
          expect(json_response['exception']).to match /cannot transition to return/
        end

        it 'and returns exception bad state' do
          put spree.api_inventory_unit_path(inventory_unit), params: {
            fire: 'bad'
          }
          expect(json_response['exception']).to match /cannot transition to bad/
        end
      end
    end
  end
end
