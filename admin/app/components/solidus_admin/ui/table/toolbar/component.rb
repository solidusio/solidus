# frozen_string_literal: true

class SolidusAdmin::UI::Table::Toolbar::Component < SolidusAdmin::BaseComponent
  erb_template <<~ERB
    <div class="
      h-14 p-2 bg-white border-b border-gray-100
      justify-start items-center gap-2
      visible:flex hidden:hidden
      rounded-t-lg
    ">
      <%= content %>
    </div>
  ERB
end
