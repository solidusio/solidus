# frozen_string_literal: true

require "spec_helper"

describe "Load samples" do
  it "doesn't raise any error" do
    expect {
      Spree::Core::Engine.load_seed
      SpreeSample::Engine.load_samples
    }.to output.to_stdout
  end

  it "doesn't change any Spree model counts when run a second time" do
    # other examples in this run (or this same example, on a re-run) may have already
    # `require`d these seed/sample files, which would make loading them a no-op against our
    # freshly truncated database
    unload_seed_files!
    unload_sample_files!
    Spree::Core::Engine.load_seed
    SpreeSample::Engine.load_samples

    Rails.application.eager_load!
    spree_models = ActiveRecord::Base.descendants.select do |model|
      model.name&.start_with?("Spree::") && !model.abstract_class? && model.table_exists?
    end
    counts_before = spree_models.index_with(&:count)

    unload_sample_files!
    SpreeSample::Engine.load_samples
    counts_after = spree_models.index_with(&:count)

    expect(counts_after).to eq(counts_before)
  end

  # bypasses the `$LOADED_FEATURES` require-guard in Spree::Sample.load_sample so the sample
  # files actually re-run, simulating a second `rake spree_sample:load` process invocation
  def unload_sample_files!
    samples_dir = Spree::Sample.send(:samples_path)
    Dir[samples_dir.join("*.rb")].each { |path| $LOADED_FEATURES.delete(File.expand_path(path)) }
  end

  # `core/db/seeds.rb` requires each seed file with `require_relative`, so once another example
  # (or a prior run within this process) has loaded them, `Spree::Core::Engine.load_seed` becomes
  # a no-op even against a freshly truncated database
  def unload_seed_files!
    $LOADED_FEATURES.reject! { |path| path.include?("db/default/spree/") }
  end
end
