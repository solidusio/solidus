# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::CalculatedAdjustments do
  let(:calculator_class) { Spree::Calculator::FlatRate }

  with_model :Calculable, scope: :all do
    model do
      include Spree::CalculatedAdjustments
    end
  end

  it "should add has_one :calculator relationship" do
    expect(Calculable.reflect_on_all_associations(:has_one).map(&:name)).to include(:calculator)
  end

  describe 'initialization' do
    context 'with no calculator' do
      subject { Calculable.new }

      it 'can be initialized' do
        expect(subject.calculator).to be nil
      end

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors[:calculator]).to eq ["can't be blank"]
      end
    end

    context 'with calculator object' do
      subject { Calculable.new(calculator: calculator_class.new) }

      it 'can be initialized' do
        expect(subject.calculator).to be_a(calculator_class)
        expect(calculator_class.count).to eq 0 # not yet saved
      end

      it 'can be created' do
        subject.save!
        expect(subject.calculator).to be_a(calculator_class)
        expect(calculator_class.count).to eq 1 # saved in database
      end
    end

    context 'with calculator_type' do
      subject { Calculable.new(calculator_type: calculator_class.to_s) }

      it 'can be initialized' do
        expect(subject.calculator).to be_a(calculator_class)
        expect(calculator_class.count).to eq 0 # not yet saved
      end

      it 'can be created' do
        subject.save!
        expect(subject.calculator).to be_a(calculator_class)
        expect(calculator_class.count).to eq 1 # saved in database
      end
    end

    context 'with calculator_type and calculator_attributes' do
      subject { Calculable.new(calculator_type: calculator_class.to_s, calculator_attributes: { preferred_amount: 123 }) }

      it 'can be initialized' do
        expect(subject.calculator).to be_a(calculator_class)
        expect(subject.calculator.preferred_amount).to eq 123
        expect(calculator_class.count).to eq 0 # not yet saved
      end

      it 'can be created' do
        subject.save!
        expect(subject.calculator).to be_a(calculator_class)
        expect(subject.calculator.preferred_amount).to eq 123
        expect(calculator_class.count).to eq 1 # saved in database
      end
    end
  end

  describe 'update' do
    subject { Calculable.create!(calculator_type: calculator_class.to_s) }

    it "can update calculator attributes with id" do
      subject.update!(calculator_attributes: {
        id: subject.calculator.id,
        preferred_amount: 123
      })
      expect(subject.calculator.preferred_amount).to eq(123)
      subject.reload
      expect(subject.calculator.preferred_amount).to eq(123)
    end

    it "can update calculator attributes without id" do
      subject.update!(calculator_attributes: {
        preferred_amount: 123
      })
      expect(subject.calculator.preferred_amount).to eq(123)
      subject.reload
      expect(subject.calculator.preferred_amount).to eq(123)
    end

    it "can update both calculator type and attributes" do
      subject.update!(calculator_type: 'Spree::Calculator::FlexiRate', calculator_attributes: {
        preferred_first_item: 123
      })
      expect(subject.calculator.class).to eq(Spree::Calculator::FlexiRate)
      expect(subject.calculator.preferred_first_item).to eq(123)
      subject.reload
      expect(subject.calculator.class).to eq(Spree::Calculator::FlexiRate)
      expect(subject.calculator.preferred_first_item).to eq(123)
    end
  end

  describe '#calculator_type=' do
    subject { Calculable.new }

    let(:calculator_subclass) { Spree::Calculator::Shipping::FlatRate }
    let(:calculator_superclass) { Spree::ShippingCalculator }

    before(:each) do
      subject.calculator_type = calculator_subclass.to_s
    end

    it 'sets calculator type' do
      expect(subject.calculator_type).to eq(calculator_subclass.to_s)
    end

    it 'switches from calculator subclass to calculator superclass' do
      subject.calculator_type = calculator_superclass.to_s
      expect(subject.calculator_type).to eq(calculator_superclass.to_s)
    end
  end
end
