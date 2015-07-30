require "rake"

shared_context "rake" do
  let(:task_name) { self.class.top_level_description }
  let(:task_path) { "lib/tasks/#{task_name.split(":").first}" }
  let(:task) { Rake::Task[task_name] }
  subject { task }

  before do
    Rake::Task.define_task(:environment)
    load File.expand_path(Rails.root + "../../#{task_path}.rake")
    task.reenable
  end
end
