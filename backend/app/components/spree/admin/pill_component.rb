# frozen_string_literal: true

class Spree::Admin::PillComponent < ActionView::Component::Base
  STATES = %i[
    active
    complete
    error
    inactive
    neutral
    pending
    text
    warning
  ]

  validates :state, inclusion: STATES, unless: -> { state.is_a? String }

  def initialize(state: "neutral", text: nil)
    @state = state
    @text = text
  end

  attr_reader :state

  def text
    @text || content || I18n.t("spree.#{state}", default: nil) || @state
  end
end
