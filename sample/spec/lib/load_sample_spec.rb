require 'spec_helper'

describe "Load samples" do
  it "doesn't raise any error" do
    expect {
      load Rails.root + 'Rakefile'
      load Rails.root + 'db/seeds.rb'

      SpreeSample::Engine.load_samples
    }.to output.to_stdout
  end
end
