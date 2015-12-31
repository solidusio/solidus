object false
child(@collection => :widgets) do
  extends "solidus/api/widgets/show"
end
node(:count) { @collection.count }
node(:current_page) { params[:page] || 1 }
node(:pages) { @collection.num_pages }
