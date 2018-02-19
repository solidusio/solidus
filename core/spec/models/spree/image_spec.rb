# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Image, type: :model do
  context '#save' do
    context 'invalid attachment' do
      let(:invalid_image) { File.open(__FILE__) }
      subject { described_class.new(attachment: invalid_image) }

      it 'returns false' do
        expect(subject.save).to be false
      end
    end

    context 'valid attachment' do
      let(:valid_image) { File.open(File.join('spec', 'fixtures', 'thinking-cat.jpg')) }
      subject { described_class.new(attachment: valid_image) }

      it 'returns true' do
        expect(subject.save).to be true
      end
    end
  end
end
