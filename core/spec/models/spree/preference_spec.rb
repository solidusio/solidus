# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Preference, type: :model do
  it "should require a key" do
    @preference = Spree::Preference.new
    @preference.key = :test
    @preference.value = true
    expect(@preference).to be_valid
  end

  describe "type conversion for values" do
    def round_trip_preference(key, value)
      element = Spree::Preference.new
      element.value = value
      element.key = key.to_s
      element.save!
      Spree::Preference.find_by(key:)
    end

    it ":boolean" do
      pref = round_trip_preference(:boolean_key, true)
      expect(pref.value).to eq true
    end

    it "false :boolean" do
      pref = round_trip_preference(:boolean_key, false)
      expect(pref.value).to eq false
    end

    it ":integer" do
      pref = round_trip_preference(:integer_key, 10)
      expect(pref.value).to eq 10
    end

    it ":decimal" do
      pref = round_trip_preference(:decimal_key, 1.5)
      expect(pref.value).to eq 1.5
    end

    it ":string" do
      pref = round_trip_preference(:string_key, "string-value")
      expect(pref.value).to eq "string-value"
    end

    it ":text" do
      pref = round_trip_preference(:text_key, "Some text")
      expect(pref.value).to eq "Some text"
    end

    it ":password" do
      pref = round_trip_preference(:password_key, "amazing-password")
      expect(pref.value).to eq "amazing-password"
    end

    it ":any" do
      pref = round_trip_preference(:any_key, [1, 2, :something])
      expect(pref.value).to eq [1, 2, :something]
    end
  end
end
