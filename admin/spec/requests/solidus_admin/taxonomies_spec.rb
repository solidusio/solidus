# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/moveable"

RSpec.describe "SolidusAdmin::TaxonomiesController", type: :request do
  it_behaves_like "requests: moveable" do
    let(:factory) { :taxonomy }
  end
end
