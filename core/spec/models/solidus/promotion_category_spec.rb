require 'spec_helper'

describe Solidus::PromotionCategory, :type => :model do
  describe 'validation' do
    let(:name) { 'Nom' }
    subject { Solidus::PromotionCategory.new name: name }

    context 'when all required attributes are specified' do
      it { is_expected.to be_valid }
    end

    context 'when name is missing' do
      let(:name) { nil }
      it { is_expected.not_to be_valid }
    end
  end
end
