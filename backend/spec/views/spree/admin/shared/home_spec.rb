require 'spec_helper'

describe 'spree/admin/dashboards/home', type: :view, partial_double_verification: false do
  it 'renders the home view' do
    render
    expect(rendered).to match('The Home view is deprecated')
  end
end
