# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'line item factory' do
  let(:factory_class) { Spree::LineItem }

  describe 'plain inventory unit' do
    let(:factory) { :line_item }

    it_behaves_like 'a working factory'
  end
end
