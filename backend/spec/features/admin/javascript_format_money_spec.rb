# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'JS Spree.formatMoney', js: true do
  stub_authorization!

  # This is a slightly hacky spec to ensure that our JS will format money in
  # the same was as our ruby code.
  # This should probably replaced with a pure JS test in the future.
  it 'should behave identically to Spree::Money#to_s' do
    visit '/admin'

    Money::Currency.all.map(&:id).map(&:to_s).map(&:upcase).uniq.each do |currency|
      money = Spree::Money.new(1234, currency: currency)

      js_result = page.evaluate_script("Spree.formatMoney(#{money.to_d}, '#{currency}')")

      expect(js_result).to eq money.to_s
    end
  end
end
