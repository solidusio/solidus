# frozen_string_literal: true

require "rails_helper"

RSpec.describe "solidus" do
  describe "delete_soft_deleted_prices" do
    include_context(
      "rake",
      task_path: Spree::Core::Engine.root.join("lib/tasks/solidus/delete_soft_deleted_prices.rake"),
      task_name: "solidus:delete_soft_deleted_prices"
    )

    it "removes all prices with non-NULL deleted_at column", :silence_deprecations do
      price = create(:price)

      price.discard!

      expect { price.reload }.not_to raise_error

      task.invoke

      expect { price.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
