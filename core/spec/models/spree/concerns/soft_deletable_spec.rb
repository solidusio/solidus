# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::SoftDeletable do
  with_model :Post do
    table do |t|
      t.datetime :deleted_at
    end

    model do
      include Spree::SoftDeletable
    end
  end

  it 'includes Paranoia' do
    expect(Post).to respond_to(:with_deleted)
    expect(Post.new).to respond_to(:deleted?)
  end

  it 'includes Discard' do
    expect(Post).to respond_to(:with_discarded)
    expect(Post.new).to respond_to(:discarded?)
    expect(Post.discard_column).to eq(:deleted_at)
  end
end
