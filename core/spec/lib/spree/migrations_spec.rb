# frozen_string_literal: true

require 'rails_helper'

module Spree
  RSpec.describe Migrations do
    let(:app_migrations) { [".", "34_add_title.rb", "52_add_text.rb"] }
    let(:engine_migrations) { [".", "334_create_orders.spree.rb", "777_create_products.spree.rb"] }

    let(:config) { double("Config", root: "dir") }

    let(:engine_dir) { "dir/db/migrate" }
    let(:app_dir) { "#{Rails.root}/db/migrate" }

    subject { described_class.new(config, "spree") }

    it "detects missing migrations" do
      expect(Dir).to receive(:entries).with(app_dir).and_return app_migrations
      expect(Dir).to receive(:entries).with(engine_dir).and_return engine_migrations

      expect(subject.missing_migrations.size).to eq 2
    end

    context "no missing migrations" do
      it "says nothing" do
        expect(Dir).to receive(:entries).with(engine_dir).and_return engine_migrations
        expect(Dir).to receive(:entries).with(app_dir).and_return(app_migrations + engine_migrations)
        expect(subject.missing_migrations.size).to eq 0
      end
    end
  end
end
