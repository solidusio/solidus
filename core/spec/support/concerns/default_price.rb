# frozen_string_literal: true

RSpec.shared_examples_for "default_price" do
  let(:model)        { described_class }
  subject(:instance) { FactoryBot.build(model.name.demodulize.downcase.to_sym) }

  describe '.has_one :default_price' do
    let(:default_price_association) { model.reflect_on_association(:default_price) }

    it 'should be a has one association' do
      expect(default_price_association.macro).to eql :has_one
    end

    it 'should have a dependent destroy' do
      expect(default_price_association.options[:dependent]).to eql :destroy
    end

    it 'should have the class name of Spree::Price' do
      expect(default_price_association.options[:class_name]).to eql 'Spree::Price'
    end
  end

  describe '#default_price' do
    subject { instance.default_price }

    describe '#class' do
      subject { super().class }
      it { is_expected.to eql Spree::Price }
    end
  end

  describe '#has_default_price?' do
    subject { super().has_default_price? }
    it { is_expected.to be_truthy }

    context 'when default price is discarded' do
      before do
        instance.default_price.discard
      end

      it { is_expected.to be_falsey }
    end
  end
end
