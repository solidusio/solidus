# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Core::ErrorReporter::Base do
  let(:error) { StandardError.new }
  let(:severity) { :error }

  describe '.report' do
    subject { described_class.report(error, severity) }

    it { expect { subject }.to raise_error NoMethodError }
  end
end
