require 'spec_helper'

describe "Template rendering", :type => :feature do

  after do
    Capybara.ignore_hidden_elements = true
  end

  before do
    Capybara.ignore_hidden_elements = false
  end

  it 'layout should have canonical tag referencing site url' do
    Solidus::Store.create!(code: 'solidus', name: 'My Spree Store', url: 'solidusstore.example.com', mail_from_address: 'test@example.com')

    visit solidus.root_path
    expect(find('link[rel=canonical]')[:href]).to eql('http://solidusstore.example.com/')
  end
end
