# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Taxon', type: :request, with_signed_in_user: true do
  let(:user) { create(:admin_user) }

  it "provides the current user to the searcher class" do
    taxon = create(:taxon, permalink: "test")
    get nested_taxons_path(taxon.permalink)

    expect(assigns[:searcher].current_user).to eq user
    expect(response.status).to eq(200)
  end
end
