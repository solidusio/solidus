require 'spec_helper'

describe Solidus::AppConfiguration, :type => :model do

  let (:prefs) { Rails.application.config.spree.preferences }

  it "should be available from the environment" do
    prefs.layout = "my/layout"
    expect(prefs.layout).to eq "my/layout"
  end

  it "should be available as Solidus::Config for legacy access" do
    expect(Solidus::Config).to be_a Solidus::AppConfiguration
  end

  it "uses base searcher class by default" do
    expect(prefs.searcher_class).to eq Solidus::Core::Search::Base
  end

  it "uses variant search class by default" do
    expect(prefs.variant_search_class).to eq Solidus::Core::Search::Variant
  end

end
