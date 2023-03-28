# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Preferences::Configuration, type: :model do
  let(:config) do
    Class.new(Spree::Preferences::Configuration) do
      preference :color, :string, default: :blue
      versioned_preference :foo, :boolean, initial_value: true, boundaries: { "3.0" => false }
    end.new
  end

  it "has named methods to access preferences" do
    config.color = 'orange'
    expect(config.color).to eq 'orange'
  end

  it "uses [ ] to access preferences" do
    config[:color] = 'red'
    expect(config[:color]).to eq 'red'
  end

  it "uses set/get to access preferences" do
    config.set(color: 'green')
    expect(config.get(:color)).to eq 'green'
  end

  it "allows defining different defaults depending on the Solidus version" do
    config.load_defaults 2.1

    expect(config.get(:foo)).to be(true)

    config.load_defaults 3.1

    expect(config.get(:foo)).to be(false)
  end

  describe '#load_defaults' do
    it 'changes loaded_defaults' do
      config.load_defaults '2.1'

      expect(config.loaded_defaults).to eq('2.1')

      config.load_defaults '3.1'

      expect(config.loaded_defaults).to eq('3.1')
    end

    it 'returns updated preferences' do
      expect(config.load_defaults('2.1')).to eq(foo: true, color: :blue)
    end

    it 'sets load_defaults_called flag to true' do
      expect(config.load_defaults_called).to be(false)

      config.load_defaults '3.1'

      expect(config.load_defaults_called).to be(true)
    end
  end

  describe '#check_load_defaults_called' do
    context 'when load_defaults_called is true' do
      it 'does not emit a warning' do
        config.load_defaults '3.1'

        expect(Spree::Deprecation).not_to receive(:warn)

        config.check_load_defaults_called
      end
    end

    context 'when load_defaults_called is false' do
      it 'emits a warning' do
        expect(Spree::Deprecation).to receive(:warn).with(/adding.*load_defaults/m)

        config.check_load_defaults_called
      end

      it 'includes constant name in the message when given' do
        expect(Spree::Deprecation).to receive(:warn).with(/Spree::Config/, any_args)

        config.check_load_defaults_called('Spree::Config')
      end
    end
  end
end
