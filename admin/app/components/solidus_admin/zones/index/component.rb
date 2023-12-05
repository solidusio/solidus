# frozen_string_literal: true

class SolidusAdmin::Zones::Index::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(page:)
    @page = page
  end

  def title
    Spree::Zone.model_name.human.pluralize
  end

  def prev_page_path
    solidus_admin.url_for(**request.params, page: @page.number - 1, only_path: true) unless @page.first?
  end

  def next_page_path
    solidus_admin.url_for(**request.params, page: @page.next_param, only_path: true) unless @page.last?
  end

  def batch_actions
    [
      {
        display_name: t('.batch_actions.delete'),
        action: solidus_admin.zones_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def filters
    []
  end

  def scopes
    []
  end

  def columns
    [
      :name,
      :description,
      {
        header: :kind,
        data: -> { component('ui/badge').new(name: _1.kind, color: _1.kind == 'country' ? :green : :blue) },
      },
      {
        header: :zone_members,
        data: -> { _1.zone_members.map(&:zoneable).map(&:name).to_sentence },
      },
    ]
  end
end
