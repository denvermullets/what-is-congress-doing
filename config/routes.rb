Rails.application.routes.draw do
  mount MissionControl::Jobs::Engine, at: '/jobs'
  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'dashboard#index'
  resources :dashboard
  post 'ingest-bills', to: 'dashboard#ingest_bills', as: :ingest_bills
end
