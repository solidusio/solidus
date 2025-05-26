# frozen_string_literal: true

RSpec.shared_examples_for "requests: moveable" do
  let(:admin_user) { create(:admin_user) }
  let(:record) { create(factory, position: 1) }
  let(:request_path) do
    solidus_admin.send("move_#{record.model_name.singular_route_key}_path", record, format: :js)
  end

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "PATCH /move" do
    it "updates record's position" do
      expect { patch request_path, params: { position: 2 } }.to change { record.reload.position }.from(1).to(2)
      expect(response).to have_http_status(:no_content)
    end
  end
end

RSpec.shared_examples_for "features: sortable" do
  let(:factory_attrs) { {} }

  before do
    create(factory, displayed_attribute => "First", position: 1, **factory_attrs)
    create(factory, displayed_attribute => "Second", position: 2, **factory_attrs)
    visit path
  end

  it "allows sorting via drag and drop" do
    row_1 = find_row("First")
    row_2 = find_row("Second")

    row_2.drag_to row_1

    expect(find("table tbody tr:first-child")).to have_text("Second")
    expect(find("table tbody tr:last-child")).to have_text("First")
  end
end
