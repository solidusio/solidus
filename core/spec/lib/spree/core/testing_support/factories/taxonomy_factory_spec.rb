# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/shared_examples/working_factory'

RSpec.describe 'taxonomy factory' do
  let(:factory_class) { Spree::Taxonomy }

  describe 'taxonomy' do
    let(:factory) { :taxonomy }

    it_behaves_like 'a working factory'
  end
end
