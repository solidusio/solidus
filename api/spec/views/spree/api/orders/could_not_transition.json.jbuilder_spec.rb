# frozen_string_literal: true

require "spec_helper"

RSpec.describe 'spree/api/orders/could_not_transition.json.jbuilder' do
  helper(Spree::Api::ApiHelpers)

  let(:template_deprecation_error) do
    'spree/api/orders/could_not_transition is deprecated.' \
    ' Please use spree/api/errors/could_not_transition'
  end

  it 'shows a deprecation error' do
    assign(:order, instance_double(Spree::Order, errors: {}))

    expect(Spree::Deprecation).to receive(:warn).with(template_deprecation_error)

    render
  end
end
