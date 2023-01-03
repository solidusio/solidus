# frozen_string_literal: true

require 'spec_helper'

describe Spree::Api::ResourceController, type: :controller do
  it "is deprecated" do
    expect(Spree::Deprecation).to receive(:warn).with(/deprecated/)

    expect(Class.new(described_class))
  end
end

