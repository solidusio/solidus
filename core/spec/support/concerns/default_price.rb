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

  describe '#find_or_build_default_price' do
    context "when default_price is already persisted" do
      it 'returns it' do
        variant = create(:master_variant, price: 55)
        variant.prices.reload

        price = variant.find_or_build_default_price

        expect(price).to eq(variant.prices[0])
        expect(price.amount).to eq(55)
      end
    end

    context "when default_price is in memory" do
      it 'returns it' do
        default_pricing_options = Spree::Config.default_pricing_options.desired_attributes
        price = build(:price, default_pricing_options)
        variant = described_class.new(prices: [price])

        expect(variant.find_or_build_default_price).to eq(price)
      end
    end

    context "when default_price is not present" do
      it 'builds and returns it' do
        default_pricing_options = Spree::Config.default_pricing_options.desired_attributes
        variant = described_class.new

        price = variant.find_or_build_default_price

        expect(price).to be_an_instance_of(Spree::Price)
        expect(
          price.attributes.values_at(*default_pricing_options.keys.map(&:to_s))
        ).to eq(default_pricing_options.values)
      end
    end
  end
end
