# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :appear_before do |expected|
  match do |actual|
    raise "Page instance required to use the appear_before matcher" unless page
    has_text? /#{actual}.*#{expected}/
  end
end
