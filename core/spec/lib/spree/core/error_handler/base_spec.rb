# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Core::ErrorHandler::Base do
  let(:error) { StandardError.new }
  let(:severity) { :error }

  describe '.handle' do
    subject { described_class.handle(error, severity) }

    it { expect { subject }.to raise_error NoMethodError }
  end
end
