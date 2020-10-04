# frozen_string_literal: true

require 'rails_helper'
require 'spree/preferences/statically_configurable'

module Spree
  RSpec.describe Preferences::StaticallyConfigurable do
    let(:superklass) do
      # Same interface activerecord's serialization would provide
      Class.new do
        attr_accessor :preferences
        def initialize
          @preferences = { color: 'blue' }
        end

        def [](key)
          return @preferences if key == :preferences
        end
      end
    end
    let(:klass) do
      Class.new(superklass) do
        include Preferences::Preferable
        include Preferences::StaticallyConfigurable

        preference :color, :string

        attr_accessor :preference_source
      end
    end

    subject do
      klass.new.tap do |item|
        item.preference_source = preference_source
      end
    end

    before do
      Spree::Config.static_model_preferences.add(klass, 'credentials', color: 'red')
    end

    describe "available_preference_sources" do
      it "should contain the defined preference sets" do
        expect(klass.available_preference_sources).to eq ['credentials']
      end
    end

    context "with no preference_source" do
      let(:preference_source) { nil }
      it "uses the persisted preference" do
        expect(subject.preferred_color).to eq "blue"
      end
    end

    context "with preference_source set" do
      let(:preference_source) { 'credentials' }
      it "uses the statically configured preference" do
        expect(subject.preferred_color).to eq "red"
      end

      it "ignores assignment" do
        subject.preferences = { color: 'orange' }
        expect(subject.preferred_color).to eq "red"
      end
    end
  end
end
