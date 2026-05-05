# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Core::ControllerHelpers::Timezone, type: :controller do
  controller(ActionController::Base) do
    include Spree::Core::ControllerHelpers::Timezone

    def index
      render plain: Time.zone.name
    end

    private

    attr_reader :spree_current_user
  end

  let(:original_timezone) { Time.zone.name }

  describe "#set_timezone" do
    context "with params[:solidus_timezone]" do
      it "sets the timezone from the param" do
        get :index, params: {solidus_timezone: "Hawaii"}
        expect(response.body).to eq("Hawaii")
      end

      it "stores the timezone in the session" do
        get :index, params: {solidus_timezone: "Hawaii"}
        expect(session[:solidus_timezone]).to eq("Hawaii")
      end

      it "takes priority over session" do
        get :index, params: {solidus_timezone: "Hawaii"}, session: {solidus_timezone: "Tokyo"}
        expect(response.body).to eq("Hawaii")
      end
    end

    context "with session[:solidus_timezone]" do
      it "uses the timezone from the session" do
        get :index, session: {solidus_timezone: "Tokyo"}
        expect(response.body).to eq("Tokyo")
      end
    end

    context "with spree_current_user timezone" do
      let(:user) { double("User", timezone: "Berlin") }

      before do
        controller.instance_variable_set(:@spree_current_user, user)
      end

      it "uses the user's timezone" do
        get :index
        expect(response.body).to eq("Berlin")
      end

      context "when user does not respond to timezone" do
        let(:user) { double("User") }

        it "falls back to the server default" do
          get :index
          expect(response.body).to eq(original_timezone)
        end
      end

      context "when user's timezone is blank" do
        let(:user) { double("User", timezone: "") }

        it "falls back to the server default" do
          get :index
          expect(response.body).to eq(original_timezone)
        end
      end
    end

    context "with an invalid timezone" do
      it "falls back to the server default" do
        get :index, params: {solidus_timezone: "Nonexistent/Zone"}
        expect(response.body).to eq(original_timezone)
      end
    end

    context "with no timezone set anywhere" do
      it "uses the server default timezone" do
        get :index
        expect(response.body).to eq(original_timezone)
      end

      it "stores the server default in session" do
        get :index
        expect(session[:solidus_timezone]).to eq(original_timezone)
      end
    end

    it "restores the original timezone after the request" do
      original = Time.zone.name
      get :index, params: {solidus_timezone: "Hawaii"}
      expect(Time.zone.name).to eq(original)
    end
  end
end
