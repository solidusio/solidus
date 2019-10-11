# frozen_string_literal: true

require 'spec_helper'

describe "Load samples" do
  it "doesn't raise any error" do
    expect {
      Solidus::Core::Engine.load_seed
      SolidusSample::Engine.load_samples
    }.to output.to_stdout
  end
end
