# frozen_string_literal: true

require 'rails_helper'

path = Spree::Core::Engine.root.join('lib/tasks/migrations/delete_prices_with_nil_amount.rake')

RSpec.describe 'solidus:migrations:delete_prices_with_nil_amount' do
  describe 'up' do
    include_context(
      'rake',
      task_path: path,
      task_name: 'solidus:migrations:delete_prices_with_nil_amount:up'
    )

    it 'removes all prices which amount column is NULL' do
      price = create(:price)
      expect(Spree::Price).to receive(:where).with(amount: nil).and_return(Spree::Price.where(id: price))

      task.invoke

      expect { price.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
