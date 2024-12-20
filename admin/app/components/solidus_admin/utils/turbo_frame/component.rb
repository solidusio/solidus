class SolidusAdmin::Utils::TurboFrame::Component < SolidusAdmin::BaseComponent
  attr_reader :id
  attr_writer :src

  def initialize(id:, src: nil)
    @id = id
    @src = src
  end
end
