# frozen_string_literal: true

# Mutant hooks (see core/.mutant.yml).
#
# The DummyApp boots with `config.eager_load = false`, so Zeitwerk loads classes
# lazily. Mutant discovers subjects from loaded constants, so without forcing
# eager loading the subject expressions can silently match nothing.
hooks.register(:env_infection_post) do
  Rails.application.eager_load!
end
