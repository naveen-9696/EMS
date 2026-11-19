# frozen_string_literal: true

Rails.application.routes.draw do
   devise_for :users,
    path: "api/v1",
    path_names: {
      sign_in: "login",
      sign_out: "logout",
      signup: "signup"
    },
    controllers: {
      sessions: "api/v1/authentication"
    },
    skip: [ :registrations, :passwords ],
    defaults: { format: :json }

    devise_scope :user do
      post "api/v1/signup", to: "api/v1/authentication#signup"
    end
    namespace :api do
      namespace :v1 do
        namespace :admin do
          resources :salary_records, only: [ :create, :index, :show ]
          resources :employees, only: [ :index, :show, :create, :update, :destroy ]
        end
      end
    end
    namespace :api do
      namespace :v1 do
        namespace :employee do
          resources :users, only: [ :index, :update, :show ]
          resources :employees do
            resources :attendance_records, only: [ :index, :show, :update ]
          end
          resources :attendance_exception_days, only:  [ :index, :show ]
          resources :attendance_records, only: [ :create, :index, :show ]
          resources :attendance_exceptions, only: [ :index, :show, :create ] do
            collection do
              post :create_leave
              post :create_regularization
            end
            member do
              put :update_leave_days
              put :update_regularization
              delete :withdraw_leave
              delete :withdraw_regularization
            end
          end
        end
      end
    end
end
