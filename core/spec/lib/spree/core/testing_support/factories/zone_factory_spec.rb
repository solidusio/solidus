# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'zone factory' do
  let(:factory_class) { Spree::Zone }

  describe 'zone' do
    let(:factory) { :zone }

    it_behaves_like 'a working factory'
  end

  describe 'global zone' do
    let(:factory) { :global_zone }

    it_behaves_like 'a working factory'
  end
end
