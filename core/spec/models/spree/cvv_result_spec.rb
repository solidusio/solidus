require 'spec_helper'

describe Spree::CVVResult, type: :model do
  CVVResult = Spree::CVVResult

  describe "#initialize" do
    it "sets code and message to nil when the argument is nil" do
      result = CVVResult.new(nil)
      expect(result.code).to be_nil
      expect(result.message).to be_nil
    end

    it "sets code and message to nil when the argument is an empty string" do
      result = CVVResult.new('')
      expect(result.code).to be_nil
      expect(result.message).to be_nil
    end

    it 'matches a code to a message' do
      result = CVVResult.new('M')
      expect(result.code).to eq('M')
      expect(result.message).to eq(CVVResult.messages['M'])
    end
  end

  describe '#to_hash' do
    it 'creates a hash with the attributes' do
      result = CVVResult.new('M').to_hash
      expect(result['code']).to eq('M')
      expect(result['message']).to eq(CVVResult.messages['M'])
    end
  end
end
