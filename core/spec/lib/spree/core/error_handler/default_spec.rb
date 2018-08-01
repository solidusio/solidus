# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Core::ErrorHandler::Default do
  let(:error) { StandardError.new }
  let(:severity) { :error }

  describe '.handle' do
    subject { described_class.handle(error, severity) }

    it 'should log with the Spree::Config.logger' do
      expect(Spree::Config.logger).to receive(:send).with(severity, error)
      subject
    end
  end
end
