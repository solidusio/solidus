# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'image factory' do
  let(:factory_class) { Spree::Image }

  describe 'plain adjustment' do
    let(:factory) { :image }

    it_behaves_like 'a working factory'
  end
end
