# frozen_string_literal: true

module SolidusAdmin::Layout::PageHelpers
  def page(**attrs, &block)
    tag.div(capture(&block), class: "px-4 relative", "data-controller": stimulus_id, **attrs) +
      tag.div(render(component("layout/feedback").new), class: "flex justify-center py-10")
  end

  def page_header_actions(&block)
    tag.div(safe_join([
      capture(&block)
    ]), class: "flex gap-2 items-center")
  end

  def page_header_back(back_path)
    render component("ui/button").back(path: back_path)
  end

  def page_header_title(title, &block)
    tag.h1(safe_join([
      tag.span(title, class: "font-semibold text-xl"),
      (capture(&block) if block) || ""
    ]), class: "flex-1 text-2xl font-bold")
  end

  def page_header(&block)
    tag.header(capture(&block), class: "py-6 flex items-center gap-4")
  end

  def page_with_sidebar(&block)
    tag.div(capture(&block), class: "flex gap-4 items-start pb-4")
  end

  def page_with_sidebar_main(&block)
    tag.div(capture(&block), class: "justify-center items-start gap-4 flex flex-col w-full")
  end

  def page_with_sidebar_aside(&block)
    tag.aside(capture(&block), class: "justify-center items-start gap-4 flex flex-col w-full max-w-sm")
  end

  def page_footer(&block)
    tag.div(capture(&block), class: "mt-4 py-4 px-2 pb-8 border-t border-gray-100 flex")
  end

  def page_footer_actions(&block)
    tag.div(capture(&block), class: "flex gap-2 grow")
  end
end
