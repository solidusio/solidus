# frozen_string_literal: true

RSpec.shared_examples_for 'a working factory' do
  it "builds successfully" do
    expect(build(factory)).to be_a(factory_class)
  end

  it "creates successfully" do
    expect(create(factory)).to be_a(factory_class)
  end

  it "is creates a valid record" do
    expect(create(factory)).to be_valid
  end
end
