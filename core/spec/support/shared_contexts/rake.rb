# frozen_string_literal: true

#
# Rake task spec setup.
#
RSpec.shared_context "rake" do |task_path:, task_name:|
  require 'rake'

  let(:task) do
    Rake::Task[task_name]
  end

  before(:each) do
    # we need to reenable the task or else `task.invoke` will only run the task
    # for the first example that runs.
    task.reenable
  end

  before(:all) do
    Rake::Task.clear
    # Note: Using `Rails.application.load_tasks` doesn't seem to work correctly
    # in the specs. The tasks each run twice when invoked instead of once.
    load task_path
    # Many tasks require the 'environment' task, which isn't needed in specs
    # since the environment is already loaded. So generate a fake one.
    Rake::Task.define_task(:environment)
  end

  after(:all) do
    Rake::Task.clear
  end
end
