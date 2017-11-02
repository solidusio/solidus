require 'spec_helper'
require 'spree/i18n'

RSpec.describe "i18n" do
  before do
    I18n.backend.store_translations(:en,
    {
      spree: {
        foo: "bar",
        bar: {
          foo: "bar within bar scope",
          invalid: nil,
          legacy_translation: "back in the day..."
        },
        invalid: nil,
        legacy_translation: "back in the day..."
      }
    })
  end

  it "translates within the spree scope" do
    expect(Spree.t(:foo)).to eql("bar")
    expect(Spree.translate(:foo)).to eql("bar")
  end

  it "prepends a string scope" do
    expect(Spree.t(:foo, scope: "bar")).to eql("bar within bar scope")
  end

  it "prepends to an array scope" do
    expect(Spree.t(:foo, scope: ["bar"])).to eql("bar within bar scope")
  end

  it "returns two translations" do
    expect(Spree.t([:foo, 'bar.foo'])).to eql(["bar", "bar within bar scope"])
  end

  it "returns reasonable string for missing translations" do
    expect(Spree.t(:missing_entry)).to include("<span")
  end

  it "should have a Spree::I18N_GENERIC_PLURAL constant" do
    expect(Spree::I18N_GENERIC_PLURAL).to eq 2.1
  end
end
