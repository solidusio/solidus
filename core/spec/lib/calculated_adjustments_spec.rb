require 'spec_helper'

describe Solidus::CalculatedAdjustments do
  it "should add has_one :calculator relationship" do
    assert Solidus::ShippingMethod.reflect_on_all_associations(:has_one).map(&:name).include?(:calculator)
  end
end
