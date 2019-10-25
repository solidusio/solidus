# frozen_string_literal: true

# Spree's rpsec controller tests get the Spree::ControllerHacks
# we don't need those for the anonymous controller here, so
# we call process directly instead of get
require 'spec_helper'

describe Spree::Admin::PillComponent, type: :component do
  def expect_html_for(*options, &block)
    expect(
      render_inline(described_class, *options, &block).css("body > *").to_html
    )
  end

  describe 'known states' do
    it 'can be active' do
      expect_html_for(state: :active).to eq(%{<span class="pill pill-active">Active</span>})
    end

    it 'can be inactive' do
      expect_html_for(state: :inactive).to eq(%{<span class="pill pill-inactive">Inactive</span>})
    end

    it 'can be complete' do
      expect_html_for(state: :complete).to eq(%{<span class="pill pill-complete">complete</span>})
    end

    it 'can be error' do
      expect_html_for(state: :error).to eq(%{<span class="pill pill-error">error</span>})
    end

    it 'can be neutral' do
      expect_html_for(state: :neutral).to eq(%{<span class="pill pill-neutral">neutral</span>})
    end

    it 'can be pending' do
      expect_html_for(state: :pending).to eq(%{<span class="pill pill-pending">Pending</span>})
    end

    it 'can be warning' do
      expect_html_for(state: :warning).to eq(%{<span class="pill pill-warning">warning</span>})
    end
  end

  it 'defaults state to "neutral"' do
    expect_html_for.to eq(%{<span class="pill pill-neutral">neutral</span>})
    expect_html_for { "Foobar" }.to eq(%{<span class="pill pill-neutral">Foobar</span>})
  end

  describe 'content' do
    it 'falls back to passed "text:", block, translation, state' do
      expect_html_for(state: "foo", text: "bar") { "baz" }.to eq(%{<span class="pill pill-foo">bar</span>})
      expect_html_for(state: "foo") { "baz" }.to eq(%{<span class="pill pill-foo">baz</span>})

      allow(I18n).to receive(:t).with("spree.foo", default: nil).and_return("FOO").once
      expect_html_for(state: "foo").to eq(%{<span class="pill pill-foo">FOO</span>})

      allow(I18n).to receive(:t).with("spree.foo", default: nil).and_return(nil).once
      expect_html_for(state: "foo").to eq(%{<span class="pill pill-foo">foo</span>})
    end
  end

  it "doesn't accept an unknown state" do
    expect{ render_inline(described_class, state: :foobar) }.to raise_error(ActiveModel::ValidationError)
    expect{ render_inline(described_class, state: nil) }.to raise_error(ActiveModel::ValidationError)
    expect{ render_inline(described_class, state: false) }.to raise_error(ActiveModel::ValidationError)
    expect{ render_inline(described_class, state: Object.new) }.to raise_error(ActiveModel::ValidationError)
  end

  it "accepts an unknown state if it's a String" do
    expect{ render_inline(described_class, state: "FOO") }.not_to raise_error
  end
end
