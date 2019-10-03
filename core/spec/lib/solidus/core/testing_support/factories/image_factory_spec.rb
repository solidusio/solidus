# frozen_string_literal: true

require 'rails_helper'
require 'solidus/testing_support/factories/image_factory'

RSpec.describe 'image factory' do
  let(:factory_class) { Solidus::Image }

  describe 'plain adjustment' do
    let(:factory) { :image }

    it_behaves_like 'a working factory'
  end
end
