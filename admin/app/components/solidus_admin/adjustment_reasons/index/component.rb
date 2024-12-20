# frozen_string_literal: true

class SolidusAdmin::AdjustmentReasons::Index::Component < SolidusAdmin::RefundsAndReturns::Component
  def model_class
    Spree::AdjustmentReason
  end

  def search_url
    solidus_admin.adjustment_reasons_path
  end

  def search_key
    :name_or_code_cont
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: solidus_admin.new_adjustment_reason_path, data: { turbo_frame: :new_adjustment_reason_modal },
      icon: "add-line",
      class: "align-self-end w-full",
    )
  end

  def turbo_frames
    return @turbo_frames if defined? @turbo_frames

    @turbo_frames = [
      component('utils/turbo_frame').new(id: dom_id(Spree::AdjustmentReason, :new)),
    ]

    @page.records.each { @turbo_frames << component('utils/turbo_frame').new(id: dom_id(_1, :edit)) }
    @turbo_frames
  end

  def row_url(adjustment_reason)
    spree.edit_admin_adjustment_reason_path(adjustment_reason, _turbo_frame: dom_id(adjustment_reason, :edit))
  end

  def batch_actions
    [
      {
        label: t('.batch_actions.delete'),
        action: solidus_admin.adjustment_reasons_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def columns
    [
      {
        header: :name,
        data: ->(adjustment_reason) do
          link_to adjustment_reason.name, row_url(adjustment_reason),
            class: 'body-link',
            data: { turbo_frame: dom_id(adjustment_reason, :edit), turbo_prefetch: false }
        end
      },
      {
        header: :code,
        data: ->(adjustment_reason) do
          link_to adjustment_reason.code, row_url(adjustment_reason),
            class: 'body-link',
            data: { turbo_frame: dom_id(adjustment_reason, :edit), turbo_prefetch: false }
        end
      },
      {
        header: :active,
        data: ->(adjustment_reason) do
          adjustment_reason.active? ? component('ui/badge').yes : component('ui/badge').no
        end
      },
    ]
  end

  def eager_loaded_frame(frame_id, src)
    frame = turbo_frames.index_by(&:id)[frame_id]
    return unless frame

    frame.src = src
  end
end
