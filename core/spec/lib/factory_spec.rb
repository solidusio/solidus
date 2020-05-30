# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Factories" do
  it "should pass linting" do
    FactoryBot.lint(FactoryBot.factories.reject{ |f| f.name == :customer_return_without_return_items })
  end
end
