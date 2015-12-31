require 'spec_helper'

describe Solidus::HomeController, :type => :controller do
  it "provides current user to the searcher class" do
    user = mock_model(Solidus.user_class, :last_incomplete_solidus_order => nil, :solidus_api_key => 'fake')
    allow(controller).to receive_messages :try_solidus_current_user => user
    expect_any_instance_of(Solidus::Config.searcher_class).to receive(:current_user=).with(user)
    solidus_get :index
    expect(response.status).to eq(200)
  end

  context "layout" do
    it "renders default layout" do
      solidus_get :index
      expect(response).to render_template(layout: 'solidus/layouts/solidus_application')
    end

    context "different layout specified in config" do
      before { Solidus::Config.layout = 'layouts/application' }

      it "renders specified layout" do
        solidus_get :index
        expect(response).to render_template(layout: 'layouts/application')
      end
    end
  end
end
