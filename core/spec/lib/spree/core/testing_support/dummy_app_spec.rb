# frozen_string_literal: true

require "rails_helper"

RSpec.describe DummyApp do
  it "loads default from the Rails version in use" do
    expect(
      DummyApp::Application.config.loaded_config_version
    ).to eq("#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}")
  end
end
