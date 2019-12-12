# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Address::Name do
  it 'concatenates components to form a full name' do
    name = described_class.new('Jane', 'Von', 'Doe')

    expect(name.to_s).to eq('Jane Von Doe')
  end

  it 'keeps first name and last name' do
    name = described_class.new('Jane', 'Doe')

    expect(name.first_name).to eq('Jane')
    expect(name.last_name).to eq('Doe')
  end

  it 'splits full name to emulate first name and last name' do
    name = described_class.new('Jane Von Doe')

    expect(name.first_name).to eq('Jane')
    expect(name.last_name).to eq('Von Doe')
  end

  context 'from attributes' do
    it 'returns name with nil first name if no relevant attribute found' do
      name = described_class.from_attributes({})

      expect(name.first_name).to be_nil
      expect(name.last_name).to be_nil
    end

    it 'prioritizes name over firstname' do
      attributes = {
        name: 'Jane Doe',
        firstname: 'Joe',
        lastname: 'Bloggs'
      }
      name = described_class.from_attributes(attributes)

      expect(name.first_name).to eq('Jane')
      expect(name.last_name).to eq('Doe')
    end

    it 'prioritizes firstname over first_name' do
      attributes = {
        firstname: 'Jane',
        lastname: 'Doe',
        first_name: 'Joe',
        last_name: 'Bloggs'
      }
      name = described_class.from_attributes(attributes)

      expect(name.first_name).to eq('Jane')
      expect(name.last_name).to eq('Doe')
    end

    it 'eventually uses first_name' do
      attributes = {
        first_name: 'Jane',
        last_name: 'Doe'
      }
      name = described_class.from_attributes(attributes)

      expect(name.first_name).to eq('Jane')
      expect(name.last_name).to eq('Doe')
    end
  end
end
