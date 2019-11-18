# frozen_string_literal: true

require "spec_helper"

describe "Spree Api Responders" do
  it "RablTemplate is deprecated Use JbuilderTemplate" do
    warning_message = /DEPRECATION WARNING: RablTemplate is deprecated! Use JbuilderTemplate instead/
    expect{ Spree::Api::Responders::RablTemplate.methods }.to output(warning_message).to_stderr
  end
end
