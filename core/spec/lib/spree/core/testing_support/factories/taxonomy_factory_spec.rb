# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'taxonomy factory' do
  let(:factory_class) { Spree::Taxonomy }

  describe 'taxonomy' do
    let(:factory) { :taxonomy }

    it_behaves_like 'a working factory'
  end
end
