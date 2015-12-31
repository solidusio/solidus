require 'spec_helper'

describe "Cancelling + Resuming", :type => :feature do

  stub_authorization!

  let(:user) { build_stubbed(:user, id: 123, solidus_api_key: 'fake') }

  before do
    allow(user).to receive(:has_solidus_role?).and_return(true)
    allow_any_instance_of(Solidus::Admin::BaseController).to receive(:try_solidus_current_user).and_return(user)
  end

  let(:order) do
    order = create(:order)
    order.update_columns({
      state: 'complete',
      completed_at: Time.current
    })
    order
  end

  it "can cancel an order" do
    visit solidus.edit_admin_order_path(order.number)
    click_button 'cancel'
    within(".additional-info") do
      expect(find('dt#order_status + dd')).to have_content("canceled")
    end
  end

  context "with a cancelled order" do
    before do
      order.update_column(:state, 'canceled')
    end

    it "can resume an order" do
      visit solidus.edit_admin_order_path(order.number)
      click_button 'resume'
      within(".additional-info") do
        expect(find('dt#order_status + dd')).to have_content("resumed")
      end
    end
  end
end
