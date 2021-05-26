# frozen_string_literal: true

require 'spec_helper'
require 'spree/core/preference_changes_between_solidus_versions'
require 'spree/preferences/configuration'

RSpec.describe Spree::Core::PreferenceChangesBetweenSolidusVersions do
  it 'includes defaults that have changed' do
    config_class = Class.new(Spree::Preferences::Configuration) do
      preference :foo, :boolean, default: by_version(true, '3.0' => false)
    end

    changes = described_class.new(config_class).call(from: '2.0', to: '3.0')

    expect(changes).to include(foo: { from: true, to: false })
  end

  it "doesn't include defaults that have not changed" do
    config_class = Class.new(Spree::Preferences::Configuration) do
      preference :foo, :boolean, default: by_version(true, '3.0' => false)
    end

    changes = described_class.new(config_class).call(from: '2.0', to: '2.5')

    expect(changes.keys).not_to include(:foo)
  end
end
