# frozen_string_literal: true

module SolidusAdmin
  class Column
    attr_reader :name, :header, :model_class_name, :position

    def initialize(
      name:,
      header:,
      position:,
      model_class_name: nil,
      data: :itself,
      renderer: ->(data) { send(:"#{name}_column", *data) },
      header_renderer: lambda do
        if respond_to?(:"#{name}_header")
          send(:"#{name}_header")
        else
          model_class_name.constantize.human_attribute_name(header)
        end
      end,
      render_context: nil
    )
      @name = name
      @header = header
      @position = position
      @data = data
      @renderer = renderer
      @header_renderer = header_renderer
      @render_context = render_context
      @model_class_name = model_class_name
    end

    def row_data(row)
      case @data
      when Symbol
        row.send(@data)
      when Proc
        @data.call(row)
      end
    end

    def render_data(row)
      data = row_data(row)

      @render_context.instance_exec(data, &@renderer)
    end

    def render_header
      @render_context.instance_exec(&@header_renderer)
    end

    def ensure_render_context(render_context)
      return self if @render_context

      self.class.new(
        name: @name,
        header: @header,
        data: @data,
        renderer: @renderer,
        header_renderer: @header_renderer,
        model_class_name: @model_class_name,
        position: @position,
        render_context: render_context
      )
    end
  end
end
