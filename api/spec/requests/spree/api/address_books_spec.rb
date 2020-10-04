# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Api::AddressBooksController, type: :request do
    let!(:state) { create(:state) }
    let!(:harry_address_attributes) do
      {
        'name' => 'Harry Potter',
        'address1' => '4 Privet Drive',
        'address2' => 'cupboard under the stairs',
        'city' => 'Surrey',
        'zipcode' => '10010',
        'phone' => '555-5555',
        'state_id' => state.id,
        'country_id' => state.country.id
      }
    end

    let!(:ron_address_attributes) do
      {
        'name' => 'Ron Weasly',
        'address1' => 'Ottery St. Catchpole',
        'address2' => '4th floor',
        'city' => 'Devon, West Country',
        'zipcode' => '10010',
        'phone' => '555-5555',
        'state_id' => state.id,
        'country_id' => state.country.id
      }
    end

    context 'as address book owner' do
      context 'with ability' do
        it 'returns my address book' do
          user = create(:user, spree_api_key: 'galleon')
          user.save_in_address_book(harry_address_attributes, true)
          user.save_in_address_book(ron_address_attributes, false)

          get "/api/users/#{user.id}/address_book",
            headers: { Authorization: 'Bearer galleon' }

          json_response = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(json_response.length).to eq(2)
          expect(json_response).to include(
            hash_including(harry_address_attributes.merge!('default' => true)),
              hash_including(ron_address_attributes.merge!('default' => false))
            )
        end

        it 'updates my address book' do
          user = create(:user, spree_api_key: 'galleon')
          address = user.save_in_address_book(harry_address_attributes, true)
          harry_address_attributes['name'] = 'Ron Weasly'

          expect {
            put "/api/users/#{user.id}/address_book",
              params:  { address_book: harry_address_attributes.merge('id' => address.id) },
              headers: { Authorization: 'Bearer galleon' }
          }.to change { UserAddress.count }.from(1).to(2)

          expect(response.status).to eq(200)
          expect(JSON.parse(response.body).first).to include(harry_address_attributes)
        end

        context 'when creating an address' do
          it 'marks the update_target' do
            user = create(:user, spree_api_key: 'galleon')

            expect {
              put "/api/users/#{user.id}/address_book",
                params:  { address_book: harry_address_attributes },
                headers: { Authorization: 'Bearer galleon' }
            }.to change { UserAddress.count }.by(1)

            user_address = UserAddress.last

            expect(response.status).to eq(200)
            update_target_ids = JSON.parse(response.body).select { |target| target['update_target'] }.map { |location| location['id'] }
            expect(update_target_ids).to eq([user_address.address_id])
          end
        end

        context 'when updating an address' do
          it 'marks the update_target' do
            user = create(:user, spree_api_key: 'galleon')
            address = user.save_in_address_book(harry_address_attributes, true)

            expect {
              put "/api/users/#{user.id}/address_book",
                params:  { address_book: harry_address_attributes },
                headers: { Authorization: 'Bearer galleon' }
            }.to_not change { UserAddress.count }

            expect(response.status).to eq(200)
            update_target_ids = JSON.parse(response.body).select { |target| target['update_target'] }.map { |location| location['id'] }
            expect(update_target_ids).to eq([address.id])
          end
        end

        it 'archives my address' do
          address = create(:address)
          user = create(:user, spree_api_key: 'galleon')
          user.save_in_address_book(address.attributes, false)

          expect {
            delete "/api/users/#{user.id}/address_book",
              params:  { address_id: address.id },
              headers: { Authorization: 'Bearer galleon' }
          }.to change { user.reload.user_addresses.count }.from(1).to(0)

          expect(response.status).to eq(200)
        end
      end
    end

    context 'on behalf of address book owner' do
      context 'with ability' do
        before do
          Spree::Config.roles.assign_permissions 'Prefect', [Spree::PermissionSets::UserManagement]
          create(:user, spree_api_key: 'galleon', spree_roles: [build(:role, name: 'Prefect')])
        end

        it "returns another user's address book" do
          other_user = create(:user)
          other_user.save_in_address_book(harry_address_attributes, true)
          other_user.save_in_address_book(ron_address_attributes, false)

          get "/api/users/#{other_user.id}/address_book",
            headers: { Authorization: 'Bearer galleon' }

          json_response = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(json_response.length).to eq(2)
          expect(json_response).to include(
            hash_including(harry_address_attributes.merge!('default' => true)),
              hash_including(ron_address_attributes.merge!('default' => false))
            )
        end

        it "updates another user's address" do
          other_user = create(:user)
          address = other_user.save_in_address_book(harry_address_attributes, true)
          updated_harry_address = harry_address_attributes.merge('name' => 'Ron Weasly')

          expect {
            put "/api/users/#{other_user.id}/address_book",
            params:  { address_book: updated_harry_address.merge('id' => address.id) },
            headers: { Authorization: 'Bearer galleon' }
          }.to change { UserAddress.count }.from(1).to(2)

          expect(response.status).to eq(200)
          expect(JSON.parse(response.body).first).to include(updated_harry_address)
        end

        it "archives another user's address" do
          address = create(:address)
          other_user = create(:user)
          other_user.save_in_address_book(address.attributes, false)

          expect {
            delete "/api/users/#{other_user.id}/address_book",
              params:  { address_id: address.id },
              headers: { Authorization: 'Bearer galleon' }
          }.to change { other_user.reload.user_addresses.count }.from(1).to(0)

          expect(response.status).to eq(200)
        end
      end

      context 'without ability' do
        it 'does not return another user address book' do
          create(:user, spree_api_key: 'galleon')
          other_user = create(:user)
          other_user.save_in_address_book(harry_address_attributes, true)

          get "/api/users/#{other_user.id}/address_book",
            headers: { Authorization: 'Bearer galleon' }

          expect(response.status).to eq(401)
        end

        it 'does not update another user address' do
          address = create(:address)
          other_user = create(:user)
          other_user_address = other_user.save_in_address_book(address.attributes, true)
          create(:user, spree_api_key: 'galleon')

          expect {
            put "/api/users/#{other_user.id}/address_book",
            params:  { address_book: other_user_address.attributes.merge('address1' => 'Hogwarts') },
            headers: { Authorization: 'Bearer galleon' }
          }.not_to change { UserAddress.count }

          expect(response.status).to eq(401)
        end

        it 'does not archive another user address' do
          address = create(:address)
          other_user = create(:user)
          other_user.save_in_address_book(address.attributes, true)
          create(:user, spree_api_key: 'galleon')

          expect {
            delete "/api/users/#{other_user.id}/address_book",
              params:  { address_id: address.id },
              headers: { Authorization: 'Bearer galleon' }
          }.not_to change { other_user.user_addresses.count }

          expect(response.status).to eq(401)
        end
      end
    end

    context 'unauthenticated' do
      before do
        @user = create(:user)
      end

      it 'GET returns a 401' do
        get "/api/users/#{@user.id}/address_book"
        expect(response.status).to eq(401)
      end

      it 'UPDATE returns a 401' do
        put "/api/users/#{@user.id}/address_book"
        expect(response.status).to eq(401)
      end

      it 'DELETE returns a 401' do
        delete "/api/users/#{@user.id}/address_book"
        expect(response.status).to eq(401)
      end
    end
  end
end
