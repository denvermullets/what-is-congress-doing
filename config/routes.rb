Rails.application.routes.draw do
  mount MissionControl::Jobs::Engine, at: '/jobs'
  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'bills#index'
  resources :dashboard
  post 'ingest-bills', to: 'dashboard#ingest_bills', as: :ingest_bills
  post 'ingest-bill-text', to: 'dashboard#ingest_bill_text', as: :ingest_bill_text
  post 'ingest-ai-text', to: 'dashboard#ingest_ai_text', as: :ingest_ai_text
end
