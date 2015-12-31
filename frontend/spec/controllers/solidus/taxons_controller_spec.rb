require 'spec_helper'

describe Solidus::TaxonsController, :type => :controller do
  it "should provide the current user to the searcher class" do
    taxon = create(:taxon, :permalink => "test")
    user = mock_model(Solidus.user_class, :last_incomplete_solidus_order => nil, :solidus_api_key => 'fake')
    allow(controller).to receive_messages :solidus_current_user => user
    expect_any_instance_of(Solidus::Config.searcher_class).to receive(:current_user=).with(user)
    solidus_get :show, :id => taxon.permalink
    expect(response.status).to eq(200)
  end
end
