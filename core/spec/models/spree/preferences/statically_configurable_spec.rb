# frozen_string_literal: true

require "rails_helper"
require "spree/preferences/statically_configurable"

module Spree
  RSpec.describe Preferences::StaticallyConfigurable do
    let(:superklass) do
      # Same interface activerecord's serialization would provide
      Class.new do
        attr_accessor :preferences
        def initialize
          @preferences = {color: "blue"}
        end

        def [](key)
          @preferences if key == :preferences
        end
      end
    end
    let(:klass) do
      Class.new(superklass) do
        include Preferences::Preferable
        include Preferences::StaticallyConfigurable

        preference :color, :string
        preference :shape, :string, default: "rect"

        attr_accessor :preference_source
      end
    end

    subject do
      klass.new.tap do |item|
        item.preference_source = preference_source
      end
    end

    before do
      Spree::Config.static_model_preferences.add(klass, "credentials", color: "red")
    end

    describe "available_preference_sources" do
      it "should contain the defined preference sets" do
        expect(klass.available_preference_sources).to eq ["credentials"]
      end
    end

    context "with no preference_source" do
      let(:preference_source) { nil }
      it "uses the persisted preference" do
        expect(subject.preferred_color).to eq "blue"
      end
    end

    context "with preference_source set" do
      let(:preference_source) { "credentials" }
      it "uses the statically configured preference" do
        expect(subject.preferred_color).to eq "red"
      end

      it "ignores assignment" do
        subject.preferences = {color: "orange"}
        expect(subject.preferred_color).to eq "red"
      end

      context "for a preference the source does not set" do
        it "falls back to the default through the reader" do
          expect(subject.preferred_shape).to eq "rect"
        end

        it "falls back to the default through the preferences hash" do
          expect(subject.preferences[:shape]).to eq "rect"
          expect(subject.preferences.to_hash[:shape]).to eq "rect"
        end

        it "keeps the statically configured value for preferences the source sets" do
          expect(subject.preferences.to_hash[:color]).to eq "red"
        end

        it "includes the defaulted preference in the keys" do
          expect(subject.preferences.keys).to match_array([:color, :shape])
        end

        it "still ignores assignment" do
          subject.preferences[:shape] = "pill"
          expect(subject.preferred_shape).to eq "rect"
        end
      end
    end
  end
end
