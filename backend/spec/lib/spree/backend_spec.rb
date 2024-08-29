# frozen_string_literal: true

require "spec_helper"
require "spree/backend"

RSpec.describe Spree::Backend do
  it "loads only the necessary Rails Frameworks" do
    aggregate_failures do
      expect(defined? ActionCable::Engine).to be_falsey
      expect(defined? ActionController::Railtie).to be_truthy
      expect(defined? ActionMailer::Railtie).to be_truthy
      expect(defined? ActionView::Railtie).to be_truthy
      expect(defined? ActiveJob::Railtie).to be_truthy
      expect(defined? ActiveModel::Railtie).to be_truthy
      expect(defined? ActiveRecord::Railtie).to be_truthy
      expect(defined? ActiveStorage::Engine).to be_truthy
      expect(defined? Rails::TestUnit::Railtie).to be_falsey
      expect(defined? Sprockets::Railtie).to be_truthy
    end
  end
end
