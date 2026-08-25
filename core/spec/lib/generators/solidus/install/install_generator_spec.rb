# frozen_string_literal: true

require "rails_helper"
require "generators/solidus/install/install_generator"

RSpec.describe Solidus::InstallGenerator do
  describe "#prepare_options" do
    it "has a default setup" do
      generator = described_class.new([], ["--auto-accept"])
      generator.prepare_options

      aggregate_failures do
        expect(generator.instance_variable_get(:@selected_frontend)).to eq("starter")
        expect(generator.instance_variable_get(:@selected_authentication)).to eq("devise")
        expect(generator.instance_variable_get(:@selected_payment_method)).to eq("paypal")
        expect(generator.instance_variable_get(:@run_migrations)).to eq(true)
        expect(generator.instance_variable_get(:@load_seed_data)).to eq(true)
        expect(generator.instance_variable_get(:@load_sample_data)).to eq(true)
      end
    end

    it 'defaults to "paypal" for payments when frontend is "starter"' do
      generator = described_class.new([], ["--auto-accept", "--frontend=starter"])
      generator.prepare_options

      aggregate_failures do
        expect(generator.instance_variable_get(:@selected_frontend)).to eq("starter")
        expect(generator.instance_variable_get(:@selected_authentication)).to eq("devise")
        expect(generator.instance_variable_get(:@selected_payment_method)).to eq("paypal")
      end
    end

    it 'disables "seeds" and "sample" if "migrate" are disabled' do
      generator = described_class.new([], ["--auto-accept", "--migrate=false"])
      generator.prepare_options

      aggregate_failures do
        expect(generator.instance_variable_get(:@run_migrations)).to eq(false)
        expect(generator.instance_variable_get(:@load_seed_data)).to eq(false)
        expect(generator.instance_variable_get(:@load_sample_data)).to eq(false)
      end
    end

    it "skips seed and sample data if migrations are disabled" do
      generator = described_class.new([], ["--auto-accept", "--migrate=false"])
      generator.prepare_options

      expect(generator.instance_variable_get(:@run_migrations)).to eq(false)
      expect(generator.instance_variable_get(:@load_seed_data)).to eq(false)
      expect(generator.instance_variable_get(:@load_sample_data)).to eq(false)
    end

    it "skips sample data if seeds are disabled" do
      generator = described_class.new([], ["--auto-accept", "--seed=false"])
      generator.prepare_options

      expect(generator.instance_variable_get(:@run_migrations)).to eq(true)
      expect(generator.instance_variable_get(:@load_seed_data)).to eq(false)
      expect(generator.instance_variable_get(:@load_sample_data)).to eq(false)
    end

    context "when asked interactively" do
      it 'presents different options for the "starter"' do
        questions = []
        generator = described_class.new([], ["--frontend=starter", "--authentication=devise"])
        allow(generator).to receive(:ask_with_description) { |**args| questions << args }

        generator.prepare_options

        expect(questions.size).to eq(1)
        expect(questions.first[:limited_to]).to eq(["paypal", "stripe", "braintree", "none"])
        expect(questions.first[:default]).to eq("paypal")
        expect(strip_ansi(questions.first[:desc])).to include("[paypal]")
        expect(strip_ansi(questions.first[:desc])).to include("[stripe]")
        expect(strip_ansi(questions.first[:desc])).not_to include("[bolt]")
        expect(strip_ansi(questions.first[:desc])).to include("[braintree]")
        expect(strip_ansi(questions.first[:desc])).to include("[none]")
      end
    end
  end

  describe "failure handling" do
    it "aborts instead of continuing when migrations fail" do
      generator = described_class.new([], ["--auto-accept"])
      generator.prepare_options
      allow(generator).to receive(:say_status)
      allow(generator).to receive(:rake).with("db:migrate", abort_on_failure: true).and_raise(Thor::Error, "migration failed")

      expect { generator.run_migrations }.to raise_error(Thor::Error, "migration failed")
    end

    it "passes abort_on_failure to the seed data rake task" do
      generator = described_class.new([], ["--auto-accept"])
      generator.prepare_options
      allow(generator).to receive(:say_status)

      # --auto-accept sets options[:auto_accept], which populate_seed_data
      # folds into rake_options as "AUTO_ACCEPT=1".
      expect(generator).to receive(:rake).with("db:seed AUTO_ACCEPT=1", abort_on_failure: true)

      generator.populate_seed_data
    end

    it "passes abort_on_failure to the sample data rake task" do
      generator = described_class.new([], ["--auto-accept"])
      generator.prepare_options
      allow(generator).to receive(:say_status)

      expect(generator).to receive(:rake).with("spree_sample:load", abort_on_failure: true)

      generator.load_sample_data
    end

    it "passes abort_on_failure to the migrations copy, database creation, and active storage rake tasks" do
      generator = described_class.new([], ["--auto-accept"])
      generator.prepare_options
      allow(generator).to receive(:say_status)

      expect(generator).to receive(:rake).with("railties:install:migrations", abort_on_failure: true)
      generator.install_migrations

      expect(generator).to receive(:rake).with("db:create", abort_on_failure: true)
      generator.create_database

      expect(generator).to receive(:rake).with("active_storage:install", abort_on_failure: true)
      generator.install_file_attachment
    end
  end

  private

  def strip_ansi(string)
    string.gsub(/\u001b\[.*?m/, "")
  end
end
