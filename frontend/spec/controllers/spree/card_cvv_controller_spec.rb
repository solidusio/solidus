# frozen_string_literal: true

require 'spec_helper'

describe Spree::CardCvvController, type: :controller do
  it "should display CVV page" do
    get :index

    expect(subject).to render_template("card_cvv/index")
  end
end
