# frozen_string_literal: true

SolidusAdmin::Engine.routes.draw do
  get 'orders', to: ->(env) { [200, {}, ['Hello from the new admin orders section!']] }
end
