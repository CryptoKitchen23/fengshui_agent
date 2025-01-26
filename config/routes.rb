Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get 'system_prompts/edit', to: 'system_prompts#edit', as: 'edit_system_prompt'
  patch 'system_prompts/update', to: 'system_prompts#update', as: 'update_system_prompt'
  get 'pump_fun_prompts/edit', to: 'pump_fun_prompts#edit', as: 'edit_pump_fun_prompt'
  patch 'pump_fun_prompts/update', to: 'pump_fun_prompts#update', as: 'update_pump_fun_prompt'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
