require 'spec_helper'

describe "solidus/checkout/_summary.html.erb", :type => :view do
  # Regression spec for #4223
  it "does not use the @order instance variable" do
    order = stub_model(Solidus::Order)
    render :partial => "solidus/checkout/summary", :locals => {:order => order}
  end
end
