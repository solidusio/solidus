# frozen_string_literal: true

# @component "ui/pagination"
class SolidusAdmin::UI::Pagination::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template(
      locals: {
        page: page_proc,
        path: path_proc
      }
    )
  end

  # @param left toggle
  # @param right toggle
  def playground(left: false, right: false)
    render current_component.new(
      page: page_proc.call(left, right),
      path: path_proc
    )
  end

  private

  def page_proc
    lambda { |left, right|
      Struct.new(:number, :next_param, :first?, :last?).new(1, '#', !left, !right)
    }
  end

  def path_proc
    ->(_page_number) { "#" }
  end
end
