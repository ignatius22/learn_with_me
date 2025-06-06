# config/routes.rb
Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  
  root "dashboard#index"
  
  # Dashboard for authenticated users
  get '/dashboard', to: 'dashboard#index'
  
  # Student profile management
  resource :profile, only: [:show, :edit, :update]
  
  # Courses with nested enrollments and reviews
  resources :courses do
    member do
      post :enroll
      delete :unenroll
    end
    
    resources :enrollments, only: [:create, :destroy, :update] do
      member do
        patch :update_status
      end
    end
    
    resources :reviews, except: [:show]
    
    # Nested sections and lessons for course structure
    resources :sections, except: [:index, :show] do
      resources :lessons, except: [:index]
    end
  end
  
  # Browse courses publicly
  get '/browse', to: 'courses#browse'
  
  # My enrollments and progress
  resources :enrollments, only: [:index, :show] do
    member do
      get :progress
      patch :update_status
    end
  end
  
  # Study area for course content delivery
  get '/study', to: 'study#index', as: 'study_index'
  get '/study/:enrollment_id', to: 'study#course', as: 'study_course'
  get '/study/:enrollment_id/lessons/:id', to: 'study#lesson', as: 'study_lesson'
  
  # AJAX endpoints for lesson progress
  post '/study/:enrollment_id/lessons/:lesson_id/complete', to: 'study#complete_lesson', as: 'complete_lesson'
  patch '/study/:enrollment_id/lessons/:lesson_id/progress', to: 'study#update_progress', as: 'update_lesson_progress'
  
  # Admin namespace for content management
  namespace :admin do
    root 'dashboard#index'
    
    resources :users do
      member do
        patch :toggle_role
      end
    end
    
    resources :authors
    resources :courses do
      resources :sections do
        resources :lessons
      end
    end
    
    resources :enrollments do
      member do
        patch :update_status
      end
    end
    
    resources :reviews, only: [:index, :show, :destroy]
    resources :roles
    
    # Analytics and reports
    get '/analytics', to: 'analytics#index'
    get '/reports', to: 'reports#index'
  end
  
  # API namespace for AJAX requests
  namespace :api do
    namespace :v1 do
      resources :courses, only: [:index, :show]
      resources :enrollments, only: [:create, :update, :destroy]
      resources :progress, only: [:update]
    end
  end
  
  # Health check
  get '/health', to: 'application#health'
end
