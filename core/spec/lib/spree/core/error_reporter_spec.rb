# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Core::ErrorReporter do
  subject { described_class }

  let(:error) { StandardError.new('Test') }

  describe '.report' do
    subject { described_class.report(error) }

    it 'should report to spree logger' do
      expect(Spree::Core::ErrorReporter::SpreeLogger).to receive(:report).
        with(error, anything, anything)

      subject
    end
  end

  describe '.reporters' do
    subject { described_class.reporters }

    it 'should contain SpreeLogger' do
      expect(subject).to include Spree::Core::ErrorReporter::SpreeLogger
    end
  end

  describe '.add_reporter' do
    subject { described_class.add_reporter(reporter) }
    let(:reporter) { Class.new(Spree::Core::ErrorReporter::Base) }

    after do
      # Reset back to default
      described_class.remove_reporter(reporter)
    end

    it 'should add the reporter' do
      expect(described_class.reporters.count).to eql 1
      subject
      expect(described_class.reporters.count).to eql 2
      expect(described_class.reporters).to include reporter
    end
  end

  describe '.remove_reporter' do
    subject { described_class.remove_reporter(reporter) }
    let(:reporter) { Class.new(Spree::Core::ErrorReporter::Base) }

    before do
      described_class.add_reporter(reporter)
    end

    it 'should remove the reporter' do
      expect(described_class.reporters.count).to eql 2
      expect(described_class.reporters).to include reporter
      subject
      expect(described_class.reporters.count).to eql 1
      expect(described_class.reporters).to_not include reporter
    end
  end
end
