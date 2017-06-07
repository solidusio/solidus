require 'spec_helper'

describe Spree::AVSResult, type: :model do
  AVSResult = Spree::AVSResult

  describe "#initialize" do
    it "accepts nil as an arguement" do
      AVSResult.new(nil)
    end

    it "sets flags indicating addresses don't match" do
      result = AVSResult.new(code: 'N')
      expect(result.code).to eq('N')
      expect(result.street_match).to eq('N')
      expect(result.postal_match).to eq('N')
      expect(result.message).to eq(AVSResult.messages['N'])
    end

    it 'sets flags indicating only the street matches' do
      result = AVSResult.new(code: 'A')
      expect(result.code).to eq('A')
      expect(result.street_match).to eq('Y')
      expect(result.postal_match).to eq('N')
      expect(result.message).to eq(AVSResult.messages['A'])
    end

    it 'sets flags indicating only the postal code matches' do
      result = AVSResult.new(code: 'W')
      expect(result.code).to eq('W')
      expect(result.street_match).to eq('N')
      expect(result.postal_match).to eq('Y')
      expect(result.message).to eq(AVSResult.messages['W'])
    end

    it 'does nothing when the code is nil' do
      result = AVSResult.new(code: nil)
      result.code
      expect(result.message).to be_nil
    end

    it 'does nothing when the code is an empty string' do
      result = AVSResult.new(code: '')
      expect(result.code).to be_nil
      expect(result.message).to be_nil
    end

    it 'can override the value of street_match' do
      avs_data = AVSResult.new(street_match: 'Y')
      expect(avs_data.street_match).to eq('Y')
    end

    it 'can override the value of postal_match' do
      avs_data = AVSResult.new(postal_match: 'Y')
      expect(avs_data.postal_match).to eq('Y')
    end
  end

  describe '#to_hash' do
    it 'returns a hash representing the object' do
      avs_data = AVSResult.new(code: 'X').to_hash
      expect(avs_data['code']).to eq('X')
      expect(avs_data['message']).to eq(AVSResult.messages['X'])
    end
  end
end
