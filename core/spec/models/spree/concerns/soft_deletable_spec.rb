# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::SoftDeletable do
  let(:soft_deletable_model) { Spree::Product }

  it 'includes Discard' do
    expect(soft_deletable_model).to respond_to(:with_discarded)
    expect(soft_deletable_model.new).to respond_to(:discarded?)
    expect(soft_deletable_model.discard_column).to eq(:deleted_at)
  end
end
