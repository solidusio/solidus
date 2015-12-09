require 'spec_helper'

feature 'Return authorizations' do
  stub_authorization!

  let!(:order) do
    exchangable_variant = create(:variant_in_stock, product: create(:product))
    create(:shipped_order, line_items_attributes: [{ variant: exchangable_variant }] )
  end

  context 'with recipient as purchaser' do
    scenario 'creates return authorization with recipient as purchaser' do
      visit spree.new_admin_order_return_authorization_path(order)
      find('.add-item').click
      select 'NY Warehouse', from: 'return_authorization_stock_location_id'

      expect {
        click_button Spree.t(:create)
      }.to change { Spree::ReturnAuthorization.count }.from(0).to(1)

      expect(page).to have_content(Spree.t(:successfully_created, resource: 'Return Authorization'))

      return_authorization = Spree::ReturnAuthorization.last
      expect(return_authorization.recipient).to eq(nil)
    end
  end

  context 'with recipient other than purchaser', :js do
    let!(:poptart_user) { create(:user, email: 'poptarts@toaster.org') }
    let!(:hello_user) { create(:user, email: 'hello@example.com') }

    scenario 'assigns recipient to return authorization' do
      visit spree.new_admin_order_return_authorization_path(order)

      within('.return-items-table') do
        expect(page).to have_content(Spree.t(:reimbursement_type).upcase)
        expect(page).to have_content(Spree.t(:exchange_for).upcase)
      end
      expect(page).not_to have_content(Spree.t(:reimbursement_recipient).upcase)

      check Spree.t(:override_recipient)

      within('.return-items-table') do
        expect(page).not_to have_content(Spree.t(:reimbursement_type).upcase)
        expect(page).not_to have_content(Spree.t(:exchange_for).upcase)
      end
      expect(page).to have_content(Spree.t(:reimbursement_recipient).upcase)

      targetted_select2 'poptarts@toaster.org', from: '#s2id_customer_search'

      find('.add-item').click
      select 'NY Warehouse', from: 'return_authorization_stock_location_id'

      expect {
        click_button Spree.t(:create)
      }.to change { Spree::ReturnAuthorization.count }.from(0).to(1)

      return_authorization = Spree::ReturnAuthorization.last
      expect(return_authorization.recipient).to eq(poptart_user)
      expect(page).to have_content(Spree.t(:successfully_created, resource: 'Return Authorization'))
    end

    scenario 'with exchange item selected' do
      visit spree.new_admin_order_return_authorization_path(order)

      targetted_select2 'Size: S', from: '#s2id_return_authorization_return_items_attributes_0_exchange_variant_id'
      select 'NY Warehouse', from: 'return_authorization_stock_location_id'

      check Spree.t(:override_recipient)
      targetted_select2 'poptarts@toaster.org', from: '#s2id_customer_search'

      expect {
        click_button Spree.t(:create)
      }.not_to change { Spree::ReturnAuthorization.count }
      expect(page).to have_content I18n.t('activerecord.errors.models.spree/return_item.attributes.exchange_variant.cannot_have_override_recipient')
    end

    scenario 'without selecting another recipient' do
      visit spree.new_admin_order_return_authorization_path(order)
      check Spree.t(:override_recipient)
      find('.add-item').click
      select 'NY Warehouse', from: 'return_authorization_stock_location_id'

      expect {
        click_button Spree.t(:create)
      }.not_to change { Spree::ReturnAuthorization.count }

      expect(page).to have_content "Recipient can't be blank"

      check Spree.t(:override_recipient)

      targetted_select2 'poptarts@toaster.org', from: '#s2id_customer_search'

      find('.add-item').click
      select 'NY Warehouse', from: 'return_authorization_stock_location_id'

      expect {
        click_button Spree.t(:create)
      }.to change { Spree::ReturnAuthorization.count }.from(0).to(1)

      return_authorization = Spree::ReturnAuthorization.last
      expect(return_authorization.recipient).to eq(poptart_user)
      expect(page).to have_content(Spree.t(:successfully_created, resource: 'Return Authorization'))
    end
  end
end
