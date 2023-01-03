# frozen_string_literal: true

require 'rails_helper'

path = Spree::Core::Engine.root.join('lib/tasks/solidus/check_orders_with_invalid_email.rake')

RSpec.describe 'solidus' do
  describe 'check_orders_with_invalid_email' do
    include_context(
      'rake',
      task_path: path,
      task_name: 'solidus:check_orders_with_invalid_email'
    )

    it 'includes orders with invalid email' do
      order = create(:order)
      order.update_column(:email, 'invalid email@email.com')

      expect { task.invoke }.to output(/invalid email@email.com \/ #{order.id} \/ #{order.number}\n/).to_stdout
    end

    it "doesn't include orders with valid email" do
      order = create(:order, email: 'valid@email.com')

      expect { task.invoke }.not_to output(/valid@email.com/).to_stdout
    end

    it "doesn't include orders with no email" do
      order = create(:order, user: nil, email: nil, number: '123')

      expect { task.invoke }.not_to output(/#{order.number}/).to_stdout
    end

    it "prints message when no matches found" do
      expect { task.invoke }.to output(/NO MATCHES/).to_stdout
    end
  end
end

