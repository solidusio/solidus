# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::UserLastUrlStorer::Rules::AuthenticationRule do
  describe '#match?' do
    let(:login_path) { '/sign_in' }
    let(:request) { double(fullpath: fullpath) }
    let(:controller) do
      double(
        request: request,
        spree_login_path: login_path,
        controller_name: 'controller_double'
      )
    end

    subject { described_class.match?(controller) }

    context 'when the request full path is an authentication route' do
      let!(:fullpath) { login_path }

      it { is_expected.to be true }
    end

    context 'when the request full path is not an authentication route' do
      let!(:fullpath) { '/products/baseball-cap' }

      it { is_expected.to be false }
    end
  end
end
