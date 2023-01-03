# frozen_string_literal: true

require 'spec_helper'
require 'spree/preferences/preference_differentiator'
require 'spree/preferences/configuration'

RSpec.describe Spree::Preferences::PreferenceDifferentiator do
  it 'includes defaults that have changed' do
    config_class = Class.new(Spree::Preferences::Configuration) do
      versioned_preference :foo, :boolean, initial_value: true, boundaries: { '3.0' => false }
    end

    changes = described_class.new(config_class).call(from: '2.0', to: '3.0')

    expect(changes).to include(foo: { from: true, to: false })
  end

  it "doesn't include defaults that have not changed" do
    config_class = Class.new(Spree::Preferences::Configuration) do
      versioned_preference :foo, :boolean, initial_value: true, boundaries: { '3.0' => false }
    end

    changes = described_class.new(config_class).call(from: '2.0', to: '2.5')

    expect(changes.keys).not_to include(:foo)
  end

  it "doesn't include not versioned defaults that can'be compared for equality" do
    config_class = Class.new(Spree::Preferences::Configuration) do
      preference :foo, :boolean, default: proc { proc { } }
    end

    changes = described_class.new(config_class).call(from: '2.0', to: '2.5')

    expect(changes.keys).not_to include(:foo)
  end
end

