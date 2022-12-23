# frozen_string_literal: true

require 'solidus/release_drafter/draft'

RSpec.describe Solidus::ReleaseDrafter::Draft do
  describe '#initialize' do
    it "encodes all line breaks in content as LF" do
      draft = described_class.new(url: nil, content: "\r\n\n\r")

      expect(draft.content).to eq("\n\n\n")
    end

    it 'allows content to be nil' do
      draft = described_class.new(url: nil, content: nil)

      expect(draft.content).to be(nil)
    end
  end
end
