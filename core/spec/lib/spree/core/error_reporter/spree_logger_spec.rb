# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Core::ErrorReporter::SpreeLogger do
  let(:error) { StandardError.new }
  let(:severity) { :error }

  describe '.report' do
    subject { described_class.report(error, severity, {}) }

    it 'should log with the Spree::Config.logger' do
      expect(Spree::Config.logger).to receive(:send).with(severity, error)
      subject
    end
  end
end
