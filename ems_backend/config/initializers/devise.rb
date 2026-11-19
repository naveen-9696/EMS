# frozen_string_literal: true

Devise.setup do |config|
  # Do not store authenticated users in Rails sessions
  config.skip_session_storage = [ :http_auth, :params_auth ]

  # API application: do not use HTML redirects for authentication
  config.navigational_formats = []

  # JWT configuration
  config.jwt do |jwt|
  jwt.secret = Rails.application.credentials.devise_jwt_secret_key!
  jwt.expiration_time = 24.hours.to_i

  jwt.dispatch_requests = [
    [ "POST", %r{^/api/v1/login$} ]
  ]

  jwt.revocation_requests = [
    [ "DELETE", %r{^/api/v1/logout$} ]
  ]

  jwt.request_formats = {
    api_v1_user: [ :json ]
  }
  end
end
