# frozen_string_literal: true

require 'rails_helper'

module Spree
  RSpec.describe Preferences::StaticModelPreferences do
    let(:preference_class) do
      Class.new do
        include Preferences::Preferable
        preference :color, :string
      end
    end
    let(:other_class){ Class.new }
    let(:definitions){ subject.for_class(preference_class) }

    it "is empty by default" do
      expect(definitions).to be_empty
    end

    it "can store preferences" do
      subject.add(preference_class, 'my_definition', {})
      # just testing that it was added here
      expect(definitions).to have_key('my_definition')
    end

    it "errors assigning invalid preferences" do
      expect {
        subject.add(preference_class, 'my_definition', { ice_cream: 'chocolate' })
      }.to raise_error(/\APreference :ice_cream is not defined/)
    end

    context "with stored definitions" do
      before do
        subject.add(preference_class, 'light', { color: 'white' })
        subject.add(preference_class, 'dark', { color: 'black' })
        subject.add(preference_class, 'no_preference', {})
      end

      describe "complete definition" do
        let(:definition){ definitions['dark'] }
        it "can fetch value" do
          expect(definition.fetch(:color)).to eq 'black'
        end

        it "can be converted to hash" do
          expect(definition.to_hash).to eq({ color: 'black' })
        end

        it "ignores assignment" do
          definition[:color] = 'maroon'
          expect(definition.fetch(:color)).to eq 'black'
          expect(definition.to_hash).to eq({ color: 'black' })
        end
      end

      describe "empty definition" do
        let(:definition){ definitions['no_preference'] }

        it "uses fallback value" do
          expect(definition.fetch(:color){ 'red' }).to eq 'red'
        end

        it "can be converted to hash" do
          expect(definition.to_hash).to eq({})
        end

        it "ignores assignment" do
          definition[:color] = 'maroon'
          expect(definition.fetch(:color){ 'red' }).to eq 'red'
          expect(definition.to_hash).to eq({})
        end
      end

      it "is still empty for other classes" do
        expect(subject.for_class(other_class)).to be_empty
      end
    end
  end
end
