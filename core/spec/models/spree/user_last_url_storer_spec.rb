# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::UserLastUrlStorer do
  subject { described_class.new(controller) }

  let(:fullpath) { '/products/baseball-cap' }
  let(:session) { {} }
  let(:request) { double(fullpath: fullpath) }
  let(:controller) do
    instance_double(
      ApplicationController,
      request: request,
      session: session,
      controller_name: 'app_controller_double'
    )
  end

  module CustomRule
    def self.match?(_controller)
      true
    end
  end

  after :each do
    described_class.rules.delete('CustomRule')
  end

  describe '::rules' do
    it 'includes default rules' do
      rule = Spree::UserLastUrlStorer::Rules::AuthenticationRule
      expect(described_class.rules).to include(rule)
    end

    it 'can add new rules' do
      described_class.rules << CustomRule
      expect(described_class.rules).to include(CustomRule)
    end
  end
end
